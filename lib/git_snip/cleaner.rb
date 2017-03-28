# frozen_string_literal: true

require 'git'

module GitSnip
  class Cleaner
    def initialize(path, target_branch = 'master', ignored_branches = [])
      @path = path
      @target_branch = target_branch
      @ignored_branches = ignored_branches
      @git = Git.init(path)
    end

    def merged_branches
      local_branches.select { |branch| merged?(branch) }
    end

    def delete_merged_branches
      checkout_target_branch

      merged_branches.map do |branch|
        delete = true
        delete = yield branch if block_given?

        if delete
          branch.delete
          branch
        else
          nil
        end
      end.to_a
    end

    private

    def local_branches
      @git.branches.local.lazy.reject do |branch|
        branch.name == @target_branch || @ignored_branches.include?(branch.name)
      end
    end

    def merged?(branch)
      @git.lib.send(:command, 'cherry', [@target_branch, branch.name])
        .each_line.all? { |line| line.start_with?('-') }
    end

    def checkout_target_branch
      @git.checkout(@target_branch)
    end
  end
end
