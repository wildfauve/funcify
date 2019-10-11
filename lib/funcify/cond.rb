module Funcify

  class Cond

    class << self

      # The little Either Cond
      # returns either the result of fn_ok || fn_fail by applying the value to test <t>.
      # > either.(Monad.maybe_value_ok, identity, Monad.maybe_value).(Success(1))  => 1
      def either
        -> test, fn_ok, fn_fail, value { test.(value) ? fn_ok.(value) : fn_fail.(value) }.curry
      end

    end

  end

end
