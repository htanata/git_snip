require 'thor'
require 'git_snip/cleaner'
require 'git_snip/branch'
require 'git_snip/config'

module GitSnip
  class CLI < Thor
    include Thor::Actions

    class << self
      def help(shell, subcommand = 'snip')
        command_help(shell, subcommand)
      end
    end

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

    option :full, type: :boolean,
      desc: 'Show most branch information without cropping.'

    desc '', 'Delete branches which have been merged to target.'
    def snip
      if opts[:dry_run]
        return dry_run
      end

      if !opts[:force]
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

    def say_branch_info(branch, full = false)
      row = opts[:full] ? Branch.full_row(branch) : Branch.row(branch)

      say row.sha + ' ', :yellow
      say row.name + ' ', :magenta
      say row.date + ' ', :green
      say row.author + ' ', [:blue, :bold]
      say row.message.strip + "\n"
    end

    def cleaner_args
      opts.values_at(:repo, :target, :ignore)
    end

    def opts
      @opts ||= begin
        config = Config.new(options[:repo])

        options_dup = options.dup

        options_dup.each_pair do |k, v|
          if v.is_a?(Array) && v.empty?
            config_value = config.options[k]

            if config_value.is_a?(Array) && config_value.any?
              options_dup[k] = config_value
            end
          end
        end

        Thor::CoreExt::HashWithIndifferentAccess.new(
          config.options.merge(options_dup)).freeze
      end
    end
  end
end
