RSpec.describe Funcify::Str do

  context '#tokeniser' do
    it 'separates a string into tokens' do
      result = Str.tokeniser.(/\s|,|\n+|\r+/).("a,b c")

      expect(result).to match_array(["a", "b", "c"])
    end

  end

end
