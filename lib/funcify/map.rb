module Funcify

  class Map

    extend Dry::Monads::Try::Mixin
    extend Dry::Monads::Result::Mixin

    class << self

      def map
        ->(f, ms) { ms.map {|k,v| f.(k,v) } }.curry
      end

      def fmap
        ->(f, ms) { ms.flat_map {|k,v| f.(k,v) } }.curry
      end

      def inject
        -> j, f, ms { ms.inject(j) {|acc, (k,v)| f.(acc).(k,v) } }.curry
      end

      def equality
        ->( field, value, i ) { i[field] == value }.curry
      end

    end # class Self

  end  # class

end  # module
