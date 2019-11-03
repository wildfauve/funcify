module Funcify

  class Str

    class << self

      def tokeniser
        -> delimiter, str { str.split(delimiter) }.curry
      end

    end # class Self

  end  # class

end  # module
