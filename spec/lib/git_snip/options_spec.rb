require 'git_snip/options'

RSpec.describe GitSnip::Options do
  describe '#merge' do
    it 'should return HashWithIndifferentAccess' do
      expect(described_class.merge)
        .to be_a(Thor::CoreExt::HashWithIndifferentAccess)
    end

    it 'should return a frozen object' do
      expect(described_class.merge).to be_frozen
    end

    it 'should prioritize primary' do
      expect(described_class.merge({ a: 1 }, { a: 2 })).to eq('a' => 1)
    end

    specify 'false on primary should override true on secondary' do
      expect(described_class.merge({ a: false }, { a: true })).to eq('a' => false)
    end

    specify 'empty array on secondary should not override' do
      expect(described_class.merge({ a: [1] }, { a: [] })).to eq('a' => [1])
    end

    specify 'empty array on primary should be overridden' do
      expect(described_class.merge({ a: [] }, { a: [2] })).to eq('a' => [2])
    end
  end
end
