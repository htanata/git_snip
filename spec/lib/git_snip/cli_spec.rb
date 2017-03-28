# frozen_string_literal: true

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

    it 'should not list ignored branches' do
      setup_basic_repo

      stdout, _, exitstatus = git_snip("--dry-run --ignore=merged")

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

  describe 'with --ignore' do
    let(:ignored_branches) { %w[ignore_1 ignore_2] }

    it 'should not delete ignored branches' do
      repo.commit('Version 1')
      repo.commit_on_branch(ignored_branches.first, 'Version 2')

      repo.commit_on_branch(
        ignored_branches.last, 'Version 3', ignored_branches.first)

      repo.merge_to_master(ignored_branches.last)

      stdout, _, exitstatus =
        git_snip("-f --ignore=#{ignored_branches.join(' ')}")

      expect(stdout).to eq(
        "Deleting the following branches...\n\n" \
        "No branches were deleted.\n"
      )
      expect(exitstatus).to eq(0)
    end
  end

  describe 'branch formatting' do
    it 'should add new line after each branch line' do
      setup_basic_repo

      stdout, _, _ = git_snip('--dry-run')

      expect(stdout).to match(/merged.+Version 2\n/)
    end
  end

  describe 'with --full' do
    it 'should not wrap the branch listing' do
      setup_basic_repo

      repo.commit_on_branch(
        'branch_with_really_long_name', "#{'A' * 100}\n\n#{'B' * 100}")

      repo.merge_to_master('branch_with_really_long_name')

      stdout, _, _ = git_snip('-n --full')

      expect(stdout).to match("#{'A' * 100}\n")
      expect(stdout).to match('branch_with_really_long_name')
    end
  end

  context 'with config file' do
    include_context 'config'

    let(:config_dir) { repo.path }

    before do
      remove_config(config_dir)
    end

    it 'should handle boolean config options' do
      setup_basic_repo

      create_config(config_dir, 'dry_run' => true)

      stdout, _, exitstatus = git_snip

      expect(exitstatus).to eq(0)
      expect(stdout).to match("Would delete the following branches...\n\n")
      expect(stdout).to match("merged")
      expect(stdout).to match("\n\nDone.")
      expect(exitstatus).to eq(0)

      expect(repo.branch_exists?('merged')).to be_truthy
    end

    it 'should set handle list config options' do
      setup_basic_repo

      create_config(config_dir, 'ignore' => ['merged'])

      stdout, _, exitstatus = git_snip('--dry-run')

      expect(stdout).to eq(
        "Would delete the following branches...\n\n" \
        "No branches would be deleted.\n"
      )

      expect(exitstatus).to eq(0)
    end

    specify 'command line arguments should override config' do
      setup_basic_repo

      create_config(config_dir, 'dry_run' => true)

      stdout, _, exitstatus = git_snip('--no-dry-run')

      expect(stdout).to eq("-f option is needed to delete branches.\n")
      expect(exitstatus).to eq(64)
    end
  end
end
