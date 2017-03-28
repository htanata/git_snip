# frozen_string_literal: true

require 'git_snip/config'

RSpec.describe GitSnip::Config do
  include_context 'config'

  let(:config_dir) { 'tmp' }

  before do
    remove_config(config_dir)
  end

  describe '#options' do
    it "should be an empty hash when config file doesn't exist" do
      expect(described_class.new(config_dir).options).to eq({})
    end

    it 'should read content of config file and convert keys to symbol' do
      options = { 'foo' => 'bar' }
      create_config(config_dir, options)

      expect(described_class.new(config_dir).options).to eq('foo' => 'bar')
    end
  end
end
