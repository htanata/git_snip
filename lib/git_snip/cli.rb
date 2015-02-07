require 'thor'
require 'git_snip/cleaner'

module GitSnip
  class CLI < Thor
    include Thor::Actions

    option :force, type: :boolean, aliases: '-f',
      desc: 'Will refuse to run unless given -f or -n.'

    option :dry_run, type: :boolean, aliases: '-n',
      desc: "Show branches which would be deleted."

    option :repo, default: '.', banner: '<path>',
      desc: 'Path to git repository.'

    option :target, default: 'master', banner: '<branch>',
      desc: 'Branch to compare equivalence against.'

    option :ignore, type: :array, default: [],
      desc: 'List of branches to ignore.'

    desc '', 'Delete branches which have been merged to target.'
    def snip
      if options[:dry_run]
        return dry_run
      end

      if !options[:force]
        say '-f option is needed to delete branches.', :red
        exit 64
      end

      cleaner = GitSnip::Cleaner.new(*cleaner_args)

      say 'Deleting the following branches...', :green
      say

      deleted_branches = cleaner.delete_merged_branches do |branch|
        say_branch_info(branch)
        true
      end

      if deleted_branches.empty?
        say 'No branches were deleted.', :green
      else
        say "\n\nDone.", :green
      end
    end
    default_task :snip

    private

    def dry_run
      cleaner = GitSnip::Cleaner.new(*cleaner_args)

      say 'Would delete the following branches...', :green
      say

      merged_branches = cleaner.merged_branches

      merged_branches.each do |branch|
        say_branch_info(branch)
      end

      if merged_branches.any?
        say "\n\nDone.", :green
      else
        say 'No branches would be deleted.', :green
      end
    end

    def say_branch_info(branch)
      say column(branch.gcommit.sha, 7), :yellow
      say column(branch.name, 12), :magenta
      say column(branch.gcommit.date.strftime('%F'), 10), :green
      say column(branch.gcommit.author.email.sub(/@.*/, ''), 8), [:blue, :bold]
      say column(branch.gcommit.message, 39, last: true)
    end

    def column(string, width, last: false)
      string[0, width].ljust(last ? width : width + 1)
    end

    def cleaner_args
      options.values_at(:repo, :target, :ignore)
    end
  end
end
