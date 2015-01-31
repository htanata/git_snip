require 'git'

class Repo
  MASTER_BRANCH = 'master'.freeze

  attr_reader :path

  def initialize(path = 'tmp/repo')
    @path = path

    destroy

    @git = Git.init(path)
  end

  def commit(text, file = 'A')
    File.open("#{path}/#{file}", 'w+') { |f| f.write("#{text}\n") }
    @git.add(all: true)
    @git.commit(text)
  end

  def commit_on_branch(branch, text, ancestor = MASTER_BRANCH)
    checkout(ancestor)
    @git.branch(branch).checkout
    commit(text)
  end

  def merge_to_master(branch)
    merge(branch, MASTER_BRANCH)
  end

  def merge(branch, target_branch)
    checkout(target_branch)
    @git.merge(branch)
  end

  def rebase_on_master(branch)
    checkout(branch)
    @git.lib.send(:command, 'rebase', MASTER_BRANCH)
  end

  def checkout(branch)
    @git.checkout(branch)
  end

  def destroy
    FileUtils.rm_rf(path)
  end

  private

  def checkout_master
    checkout(MASTER_BRANCH)
  end
end
