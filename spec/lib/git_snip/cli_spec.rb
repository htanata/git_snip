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
    it 'should delete branches merged to master' do
      setup_basic_repo

      stdout, _, exitstatus = git_snip('-f')

      expect(stdout).to match("Deleting the following branches...\n\n")
      expect(stdout).to match("merged")
      expect(stdout).to match("\n\nDone.")
      expect(exitstatus).to eq(0)

      expect(repo.branch_exists?('merged')).to be_falsey
    end

    it 'should show decent message when there are no deleted branches' do
      repo.commit 'Version 1'

      stdout, _, exitstatus = git_snip('-f')

      expect(stdout).to eq(
        "Deleting the following branches...\n\n" \
        "No branches were deleted.\n"
      )

      expect(exitstatus).to eq(0)
    end
  end

  describe 'with --dry-run' do
    it 'should list branches merged to master' do
      setup_basic_repo

      stdout, _, exitstatus = git_snip('--dry-run')

      expect(stdout).to match("Would delete the following branches...\n\n")
      expect(stdout).to match("merged")
      expect(stdout).to match("\n\nDone.")
      expect(exitstatus).to eq(0)

      expect(repo.branch_exists?('merged')).to be_truthy
    end

    it 'should show decent message when branch list is empty' do
      repo.commit 'Version 1'

      stdout, _, exitstatus = git_snip('--dry-run')

      expect(stdout).to eq(
        "Would delete the following branches...\n\n" \
        "No branches would be deleted.\n"
      )

      expect(exitstatus).to eq(0)
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
