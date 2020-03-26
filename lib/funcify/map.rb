module Funcify

  class Map

    extend Dry::Monads::Try::Mixin
    extend Dry::Monads::Result::Mixin

    class << self

      def map
        ->(f, ms) { ms.map {|k,v| f.(k,v) } }.curry
      end

      def any?
        ->(f, ms) { ms.any? {|k,v| f.(k,v) } }.curry
      end

      def fmap
        ->(f, ms) { ms.flat_map {|k,v| f.(k,v) } }.curry
      end

      def inject
        -> j, f, ms { ms.inject(j) {|acc, (k,v)| f.(acc).(k,v) } }.curry
      end

      def select
        -> f, ms { ms.select {|k,v| f.(k,v) } }.curry
      end

      def equality
        -> field, test_value, i {
          if field.kind_of?(Proc)
            field.(i) == test_value
          else
            i[field] == test_value
          end
        }.curry

      end

    end # class Self

  end  # class

end  # module
