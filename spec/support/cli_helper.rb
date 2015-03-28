require 'git_snip/cli'
require_relative 'cli_runner'

module CliHelper
  class FakeKernel
    attr_reader :exitstatus

    def initialize
      @exitstatus = 0
    end

    def exit(exitstatus)
      @exitstatus = exitstatus
    end
  end

  def git_snip(args = '', blank_slate = false)
    stdin, stdout, stderr = Array.new(3) { StringIO.new }

    arguments = args.dup
    arguments << " --repo=#{repo.path}" unless blank_slate

    runner =
      GitSnip::CLIRunner.new(arguments.split(' '),
        stdin, stdout, stderr, FakeKernel.new)

    exitstatus = runner.execute!

    [stdin, stdout, stderr].each(&:rewind)

    [stdout.read, stderr.read, exitstatus]
  end

  def setup_basic_repo
    repo.commit('Version 1')
    repo.commit_on_branch('merged', 'Version 2')
    repo.merge_to_master('merged')
  end

  private

  def lib
    File.expand_path('../../lib', __FILE__)
  end

  def bin
    File.expand_path('../../../bin/git-snip', __FILE__)
  end
end
