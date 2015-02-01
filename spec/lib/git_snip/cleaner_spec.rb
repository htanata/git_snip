require 'git_snip/cleaner'

RSpec.describe GitSnip::Cleaner do
  let(:repo) { Repo.new }
  let(:cleaner) { described_class.new(repo.path, Repo::MASTER_BRANCH) }

  after do
    repo.destroy
  end

  describe '#merged_branches' do
    it 'should return branches that have been merged' do
      repo.commit('Version 1')
      repo.commit_on_branch('version_2', 'Version 2')
      repo.merge_to_master('version_2')

      expect(names(cleaner.merged_branches)).to match_array(%w[version_2])
    end

    it 'should return branches whose copy has been rebased and merged' do
      repo.commit('Version 1')
      repo.commit_on_branch('version_2', 'Version 2')
      repo.commit_on_branch('version_3', 'Version 3', 'version_2')
      repo.checkout('master')
      repo.commit('Version 4', 'B')
      repo.rebase_on_master('version_3')
      repo.merge_to_master('version_3')

      expect(names(cleaner.merged_branches))
        .to match_array(%w[version_2 version_3])
    end

    it 'should not return branches that have not been merged' do
      repo.commit('Version 1')
      repo.commit_on_branch('version_2', 'Version 2')

      expect(cleaner.merged_branches.any?).to be_falsey
    end

    context 'non master target_branch' do
      let(:target_branch) { 'target_it' }
      let(:cleaner) { described_class.new(repo.path, target_branch) }

      it 'should return branches that have been merged' do
        repo.commit('Version 1')
        repo.commit_on_branch(target_branch, 'Version 2')
        repo.merge('master', target_branch)

        expect(names(cleaner.merged_branches)).to match_array(%w[master])
      end
    end

    context 'with ignored branches' do
      let(:ignored_branch) { 'ignore_me' }

      let(:cleaner) do
        described_class.new(repo.path, Repo::MASTER_BRANCH, [ignored_branch])
      end

      it 'should not return ignored branches that have been merged' do
        repo.commit('Version 1')
        repo.commit_on_branch(ignored_branch, 'Version 2')
        repo.merge_to_master(ignored_branch)

        expect(cleaner.merged_branches.any?).to be_falsey
      end
    end
  end

  describe '#delete_merged_branches' do
    it 'should delete branches that have been merged' do
      repo.commit('Version 1')
      repo.commit_on_branch('version_2', 'Version 2')
      repo.merge_to_master('version_2')

      deleted_branches = cleaner.delete_merged_branches { true }

      expect(names(deleted_branches)).to eq(%w[version_2])
      expect(repo.branch_exists?('version_2')).to be_falsey
    end

    it 'should yield branches to be deleted' do
      repo.commit('Version 1')
      repo.commit_on_branch('version_2', 'Version 2')
      repo.merge_to_master('version_2')

      cleaner.delete_merged_branches do |branch|
        expect(branch.name).to eq('version_2')
      end
    end

    it 'should not delete branches that have not been merged' do
      repo.commit('Version 1')
      repo.commit_on_branch('version_2', 'Version 2')

      deleted_branches = cleaner.delete_merged_branches { true }

      expect(names(deleted_branches)).to be_empty
      expect(repo.branch_exists?('version_2')).to be_truthy
    end

    it 'should be able to delete branches that is currently active' do
      repo.commit('Version 1')
      repo.commit_on_branch('version_2', 'Version 2')
      repo.merge_to_master('version_2')
      repo.checkout('version_2')

      deleted_branches = cleaner.delete_merged_branches { true }

      expect(names(deleted_branches)).to eq(%w[version_2])
      expect(repo.branch_exists?('version_2')).to be_falsey
    end

    it 'should not delete branch when block returns false' do
      repo.commit('Version 1')
      repo.commit_on_branch('version_2', 'Version 2')
      repo.commit_on_branch('version_3', 'Version 3', 'version_2')
      repo.merge_to_master('version_3')

      deleted_branches = cleaner.delete_merged_branches do |branch|
        branch.name != 'version_2'
      end

      expect(deleted_branches.size).to eq(2)
      expect(deleted_branches).to include(nil)
      expect(names(deleted_branches.compact)).to eq(['version_3'])

      expect(repo.branch_exists?('version_2')).to be_truthy
      expect(repo.branch_exists?('version_3')).to be_falsey
    end
  end

  def names(branches)
    branches.map(&:name)
  end
end
