require 'open3'

module CliHelper
  def git_snip(args = '')
    cmd = "#{Gem.ruby} -I#{lib} #{bin} #{cmd} #{args} --repo=#{repo.path}"

    stdout, stderr, status = Open3.capture3(cmd)

    [stdout, stderr, status.exitstatus]
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
