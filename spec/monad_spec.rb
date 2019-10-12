RSpec.describe Monad do

  context '#success' do
    it 'wraps result in success' do
      result = Monad.success.(:ok)
      expect(result).to be_success
      expect(result.value_or).to eq :ok
    end
  end

  context '#lift' do
    it 'returns the lifted result when success' do
      result = Monad.lift.(M.Success(:ok))
      expect(result).to eq :ok
    end

    it 'returns the lifted result when failure' do
      result = Monad.lift.(M.Failure(:error))
      expect(result).to eq :error
    end

    # it 'lifts a Try failure' do
    #   include Dry::Monads::Try::Mixin
    #   result = Monad.lift.(Try { 0/1 } )
    #   binding.pry
    # end

  end

end
