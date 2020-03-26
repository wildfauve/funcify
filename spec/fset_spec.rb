RSpec.describe FSet do

  context '#subset' do
    it 'is a subset when arrays' do
      result = FSet.subset?.([1,2]).([1,2,3])

      expect(result).to be true
    end

    it 'is a superset' do
      result = FSet.superset?.([1,2,3]).([1,2])

      expect(result).to be true

    end

    it 'is eq' do
      result = FSet.eq?.([1,2,3]).([1,2,3])

      expect(result).to be true

    end


  end

end
