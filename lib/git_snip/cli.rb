require 'thor'
require 'git_snip/cleaner'
require 'git_snip/branch'

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

      say "Deleting the following branches...\n\n", :green

      deleted_branches = cleaner.delete_merged_branches do |branch|
        say_branch_info(branch)
        true
      end

      if deleted_branches.empty?
        say 'No branches were deleted.', :green
      else
        say "\nDone.", :green
      end
    end
    default_task :snip

    private

    def dry_run
      cleaner = GitSnip::Cleaner.new(*cleaner_args)

      say "Would delete the following branches...\n\n", :green

      merged_branches = cleaner.merged_branches

      merged_branches.each do |branch|
        say_branch_info(branch)
      end

      if merged_branches.any?
        say "\nDone.", :green
      else
        say 'No branches would be deleted.', :green
      end
    end

    def say_branch_info(branch)
      Branch.columnize(branch).tap do |column|
        say column.sha + ' ', :yellow
        say column.name + ' ', :magenta
        say column.date + ' ', :green
        say column.author + ' ', [:blue, :bold]
        say column.message.strip + "\n"
      end
    end

    def cleaner_args
      options.values_at(:repo, :target, :ignore)
    end
  end
end
