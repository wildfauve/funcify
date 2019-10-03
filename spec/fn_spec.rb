RSpec.describe Funcify::Fn do

  context '#fmap_compose' do

    it 'runs all fns and returns success' do
      f1 = ->(v) { M.Success(v + 1) }
      f10 = ->(v) { M.Success(v + 10) }

      result = Funcify::Fn.fmap_compose.([f1, f10]).(M.Success(0))
      expect(result).to be_success
      expect(result.value_or).to eq 11
    end

    it 'runs terminates when a failure is returned with the failure value' do
      f1 = ->(v) { M.Success(v + 1) }
      f10 = ->(v) { M.Failure(v) }
      f100 = ->(v) { M.Success(v + 100) }

      result = Funcify::Fn.fmap_compose.([f1, f10, f100]).(M.Success(0))
      expect(result).to be_failure
      expect(result.failure).to eq 1
    end

  end

  context '#wrapper' do

  end

  context '#equality' do

    it 'successfully matches the field with the value' do
      expect(Funcify::Fn.equality.(:a).("equal").({a: "equal"})).to be true
    end

    it 'uses a fn to extract the test property' do
      test_fn = -> x { x[:a] }
      expect(Funcify::Fn.equality.(test_fn).("equal").({a: "equal"})).to be true
    end
  end

  context '#partition' do

    it 'partitions an enumeration by the function' do
      expect(Funcify::Fn.partition.(-> x { x == 1 }).([1,1,2,3,4])).to match_array([[1,1],[2,3,4]])
    end

  end

  context '#uniq' do

    it 'creates a new collection with only unique values' do
      expect(Funcify::Fn.uniq.(Funcify::Fn.identity).([1,1,2])).to match_array([1,2])
    end

  end


end
