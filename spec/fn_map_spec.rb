RSpec.describe Funcify::Map do

  context '#inject' do
    it 'adds numbers from a map value' do
      adder = -> acc, k, v { acc += v }.curry
      result = Funcify::Map.inject.(0).(adder).({a: 1, b: 2})
      expect(result).to eq(3)
    end
  end

  context '#map' do
    it 'creates a list containing each k/v' do
      xform = -> k, v { {k => v} }.curry
      result = Funcify::Map.map.(xform).({a: 1, b: 2})
      expect(result).to eq([{a:1}, {b:2}])
    end
  end

end
