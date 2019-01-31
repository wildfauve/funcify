module Funcify

  class Record

    extend Dry::Monads::Try::Mixin
    extend Dry::Monads::Result::Mixin

    class << self

      def equality
        ->( prop, value, r ) { r.send(prop) == value }.curry
      end

      def at
        -> method, r { r.send(method) }.curry
      end

      def apply_value
        -> r, method, v { r.send(method, v) }.curry
      end

      def prop
        -> method, r { r.send(method) }.curry
      end


    end # class Self

  end  # class

end  # module
