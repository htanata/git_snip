require 'open3'

module CliHelper
  def git_snip(args = '')
    cmd = "#{Gem.ruby} -I#{lib} #{bin} #{cmd} #{args} --repo=#{repo.path}"

    stdout, stderr, status = Open3.capture3(cmd)

    [stdout, stderr, status.exitstatus]
  end

  private

  def lib
    File.expand_path('../../lib', __FILE__)
  end

  def bin
    File.expand_path('../../../bin/git-snip', __FILE__)
  end
end
