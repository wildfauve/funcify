RSpec.describe Funcify::Cond do

  context '#either' do
    it 'returns the success result when the test results in true' do
      result = Cond.either.(Monad.maybe_value_ok?, Monad.maybe_value, Monad.maybe_failure).(M.Success(1))

      expect(result).to eq 1
    end

    it 'returns the failure result when the test results in false' do
      result = Cond.either.(Monad.maybe_value_ok?, Monad.maybe_value, Monad.maybe_failure).(M.Failure(:error))

      expect(result).to eq :error
    end

  end

end
