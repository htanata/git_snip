require 'git_snip/cli'

RSpec.describe GitSnip::CLI do
  include CliHelper

  let(:repo) { Repo.new }

  after do
    repo.destroy
  end

  describe 'without -f' do
    it 'should exit with error message' do
      stdout, _, exitstatus = git_snip
      expect(stdout).to eq("-f option is needed to delete branches.\n")
      expect(exitstatus).to eq(64)
    end
  end

  describe 'with -f' do
    before do
      setup_basic_repo
    end

    it 'should delete branches merged to master' do
      stdout, _, exitstatus = git_snip('-f')

      expect(stdout).to match("Deleting the following branches...\n\n")
      expect(stdout).to match("merged")
      expect(stdout).to match("\n\nDone.")
      expect(exitstatus).to eq(0)

      expect(repo.branch_exists?('merged')).to be_falsey
    end
  end

  describe 'with --dry-run' do
    before do
      setup_basic_repo
    end

    it 'should list branches merged to master' do
      stdout, _, exitstatus = git_snip('--dry-run')

      expect(stdout).to match("Would delete the following branches...\n\n")
      expect(stdout).to match("merged")
      expect(stdout).to match("\n\nDone.")
      expect(exitstatus).to eq(0)

      expect(repo.branch_exists?('merged')).to be_truthy
    end
  end

  describe 'with --target' do
    let(:target) { 'target_it' }

    before do
      repo.commit('Version 1')
      repo.commit_on_branch(target, 'Version 2')
      repo.merge('master', target)
    end

    it 'should delete merged branches' do
      stdout, _, exitstatus = git_snip("-f --target=#{target}")

      expect(stdout).to match("Deleting the following branches...\n\n")
      expect(stdout).to match("master")
      expect(stdout).to match("\n\nDone.")
      expect(exitstatus).to eq(0)

      expect(repo.branch_exists?('master')).to be_falsy
    end
  end
end
