RSpec.describe Map do

  context '#inject' do
    it 'adds numbers from a map value' do
      adder = -> acc, k, v { acc += v }.curry
      result = Map.inject.(0).(adder).({a: 1, b: 2})
      expect(result).to eq(3)
    end
  end

  context '#map' do
    it 'creates a list containing each k/v' do
      xform = -> k, v { {k => v} }.curry
      result = Map.map.(xform).({a: 1, b: 2})
      expect(result).to eq([{a:1}, {b:2}])
    end
  end

  context '#select' do
    it 'selects from map containing each k/v' do
      selecter = -> k, v { v == 1 }.curry
      result = Map.select.(selecter).({a: 1, b: 2})
      expect(result).to eq({a:1})
    end
  end


  context '#any?' do
    it 'determines if any value meets the predicate for each k/v' do
      predicate = -> k, v { v == 1 }.curry
      expect(Map.any?.(predicate).({a: 1, b: 2})).to be true
    end
  end


end
