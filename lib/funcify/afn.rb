module Funcify

  class Afn

    extend Dry::Monads::Result::Mixin

    PRIVILEGE = :privilege
    RESOURCE  = :resource

    class << self

      #
      # Authorise Fns
      #
      # @param enforcer  A fn that responds to #call and is invoked when the authorisations fail
      # @param policy_predicates  An array of Policy Predicates.  The policy takes optional state and ctx and returns a Maybe. Available checkers are:
      #                  + Afn.activity_policy
      #                  + Afn.privilege_policy
      #                  + Afn.slack_token_policy
      # @param ctx       A data structure of the user's authz context understood by the policy checker; e.g. the activity being performed
      # Example
      # > Afn.authorise.(Afn.auth_error_raise_enforcer.(PolicyEnforcement::AuthorisationFailed))
      #                .([Afn.activity_policy.(system_policy)])
      #                .(activity_ctx(:create))
      # => Success(nil) | raises a PolicyEnforcement::AuthorisationFailed
      # Use partial evaluation by establishing the enforcer and policies (which returns a partially applied authorise fn)
      # passing this to the services to be protected, which that evaluate the fn by providing the ctx.
      def authorise
        -> enforcer, policies, ctx {
          Fn.compose.(  finally_fn.(enforcer),
                        Fn.fmap_compose.(policies)
            ).(Success(ctx))
        }.curry
      end

      # alias of #authorise, which works with fmapping; hence all policy checks MUST be Success
      def all_authorisor
        -> enforcer, policies, ctx {
          Fn.compose.(  finally_fn.(enforcer),
                        Fn.fmap_compose.(policies)
            ).(Success(ctx))
        }.curry
      end

      # Similar to all_authorisor, except at least one of the policies MUST be success
      def or_authorisor
        -> enforcer, policies, ctx {
          Fn.compose.(  any_finally_fn.(enforcer),
                        Fn.map.(-> policy { policy.(ctx) } )
            ).(policies)
        }.curry
      end

      def finally_fn
        -> enforcer, v { Fn.either.(Fn.maybe_value_ok?).(Fn.identity).(-> x { enforcer.(x) } ).(v) }.curry
      end

      # any results Success(), then Success, otherwise call enforcer
      def any_finally_fn
        -> enforcer, results {
          Fn.either.(Fn.any?.(Fn.maybe_value_ok?), Fn.success).(-> x { enforcer.(x) }).(results)
       }.curry
      end

      #
      # Enforcement Fns
      def nil_enforcer
        Fn.identity
      end

      def error_raiser
        -> exception, ctx { raise exception unless ctx.success? }.curry
      end

      #
      # Policy Predicate Fns
      # ====================
      #
      # A Policy Predicate takes a context (any data structure it might or might not undestand), performs predicate
      # tests using the context and the state, and returns an Either (Success or Failure)
      # The ctx is specific to the test
      #

      #
      # Valid JWT test
      # --------------
      #
      # Takes any data structure and a function which validates it.
      def validity_policy
        -> policy_predicates, ctx {
          Fn.either.(Fn.tests.(Fn.all?, policy_predicates), Fn.success, Fn.failure ).(ctx)
        }.curry
      end

      # Slack Policy
      # ------------
      # Slack Policy looks for :token in the ctx, and ensures that token is configured in Account.
      # @param ctx {} expects a :token key/value provided by Slack.
      def slack_token_policy
        -> expected_token, ctx { Fn.either.(Fn.tests.(Fn.all?, slack_token_tests(expected_token)), Fn.success, Fn.failure ).(ctx) }.curry
      end

      def slack_token_tests(token)
        [
          key_present_test.(:token),
          valid_slack_token.(token)
        ]
      end

      # The Activity-based access control policy
      # ----------------------------------------
      # @param activities [String] A collection of activity strings assigned to the user obtained from Identity.  For example:
      #                            => ["lic:account:resource:billing_entity:*","lic:account:resource:payment_method:*"]
      # @param filter_fn  A fn used to filter the activities.  Afn provides a #for_system fn which removes
      #                   any activities not associated with the system under test.  Fn.identity could be used to retain
      #                   all activities, or you can use any other fn that takes the activities as the last param
      # @param ctx {}  service/resource/action being tested; e.g. {:resource=>:invoice, :action=>:create}
      # Policy runs 4 tests:
      # + the ctx includes a :resource key
      # + the ctx includes an :action key
      # + the ctx includes an :activities
      # + and finally, the significant test, the service/resource/action match an activity
      def activity_policy
        -> activities, filter_fn, ctx {
          Fn.either.( Fn.tests.(Fn.all?, activity_tests), Fn.success, Fn.failure ).(ctx.merge(activities: filter_fn.(activities)))
        }.curry
      end

      def activity_tests
        [
          key_present_test.(:resource),
          key_present_test.(:action),
          key_present_test.(:activities),
          has_activity.(resource_activity_policy_tests)
        ]
      end

      # The Privelged access control policy
      # ----------------------------------------
      # @param activities [String] A collection of activity strings assigned to the user obtained from Identity.  For example:
      #                            => ["lic:account:privilege:billing_entity:*","lic:account:privilege:payment_method:*"]
      # @param filter_fn  A fn used to filter the activities.  Afn provides a #for_system fn which removes
      #                   any activities not associated with the system under test.  Fn.identity could be used to retain
      #                   all activities, or you can use any other fn that takes the activities as the last param
      # @param ctx {}  service/resource/action being tested for privileged access; e.g. {:resource=>:invoice, :action=>:create}
      # Policy runs 4 tests:
      # + the ctx includes a :privilege key
      # + the ctx includes an :action key
      # + the ctx includes an :activities
      # + and finally, the significant test, the service/resource/action match an activity
      def privilege_policy
        -> activities, filter_fn, ctx {
          Fn.either.(Fn.tests.(Fn.all?, privilege_tests), Fn.success, Fn.failure ).(ctx.merge(activities: filter_fn.(activities)))
        }.curry
      end

      def privilege_tests
        [
          key_present_test.(:privilege),
          key_present_test.(:action),
          key_present_test.(:activities),
          has_privileged_access.(privilege_activity_policy_tests)
        ]
      end


      #
      # Helper Fns
      #

      def for_system
        -> system, activities {
          Fn.remove.(-> a { !a.include?(system.to_s)}).(activities)
        }.curry
      end

      def key_present_test
        -> k, ctx { ctx.has_key? k }.curry
      end

      def valid_slack_token
        -> t, ctx { ctx[:token] == t }.curry
      end

      # s: system
      # r: r
      # a: action
      # activitys: user's activity enum
      def has_activity
        -> tests, ctx  {
          activity_match.(tests, ctx[:resource], ctx[:action]).(ctx[:activities])
        }.curry
      end

      def has_privileged_access
        -> tests, ctx  {
          activity_match.(tests, ctx[:privilege], ctx[:action]).(ctx[:activities])
        }.curry
      end


      def activity_match
        -> tests, r, a, activities {
          Fn.find.(policy_match.(tests, r, a)).(activities)
        }.curry
      end

      def policy_match
        -> tests, r, a, activity {
          Fn.compose.(  activity_token_matcher.(tests, r,a),
                        Fn.coherse.(:to_sym),
                        Fn.split.(":")
            ).(activity)
        }.curry
      end

      def activity_token_matcher
        -> tests, r, a, tokens {
          Fn.tests.(Fn.all?, tests.(r, a)).(tokens)
        }.curry
      end

      def privilege_activity_policy_tests
        -> r, a {
          [
            has_priviled.(r),
            resource_test.(r),
            action_test.(a)
          ]
        }
      end

      def resource_activity_policy_tests
        -> r, a {
          [
            has_resource.(r),
            resource_test.(r),
            action_test.(a)
          ]
        }
      end

      def system_test
        -> req, token { token_match.(req).(Fn.at.(1).(token)) }.curry
      end

      def has_resource
        -> req, token { Fn.at.(2,token) == RESOURCE }.curry
      end

      def has_priviled
        -> req, token { Fn.at.(2,token) == PRIVILEGE }.curry
      end

      def resource_test
        -> req, token { token_match.(req).(Fn.at.(3).(token)) }.curry
      end

      def action_test
        -> req, token { token_match.(req).(Fn.at.(4).(token)) }.curry
      end

      def token_match
        -> req, token {
          # req.nil? || req.size == 0 || token == :* || token == req
          token == :* || token == req
        }.curry
      end

    end

  end

end
