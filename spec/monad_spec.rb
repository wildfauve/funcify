RSpec.describe Funcify::Monad do

  context '#success' do
    it 'wraps result in success' do
      result = Funcify::Monad.success.(:ok)
      expect(result).to be_success
      expect(result.value_or).to eq :ok
    end
  end

  context '#lift' do
    it 'returns the lifted result when success' do
      result = Funcify::Monad.lift.(M.Success(:ok))
      expect(result).to eq :ok
    end

    it 'returns the lifted result when failure' do
      result = Funcify::Monad.lift.(M.Failure(:error))
      expect(result).to eq :error
    end

  end

end
