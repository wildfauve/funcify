module Funcify

  class FSet

    class << self

      def subset?
        -> subset, superset { to_set(subset).subset?(to_set(superset)) }.curry
      end

      def superset?
        -> superset, subset { to_set(superset).superset?(to_set(subset)) }.curry
      end

      def eq?
        -> seta, setb { to_set(seta) == (to_set(setb)) }.curry
      end

      def to_set(array_or_set)
        array_or_set.instance_of?(Array) ? Set.new(array_or_set) : array_or_set
      end

    end

  end

end
