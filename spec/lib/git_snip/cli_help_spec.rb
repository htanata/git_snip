# frozen_string_literal: true

require 'git_snip/cli'

RSpec.describe GitSnip::CLI, 'help' do
  include CliHelper

  it 'should display help for snip subcommand' do
    stdout, _, _ = git_snip('help', :blank_slate)
    expect(stdout).to match('--force')
    expect(stdout).to match('--dry-run')
  end
end
