# frozen_string_literal: true

require 'thor'
require 'git_snip/cleaner'
require 'git_snip/branch'
require 'git_snip/config'
require 'git_snip/printer'
require 'git_snip/options'

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
      desc: 'Show branches which would be deleted.'

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
        printer.force_option_needed
        exit 64
      end

      cleaner = GitSnip::Cleaner.new(*cleaner_args)

      printer.deleting_branches

      deleted_branches = cleaner.delete_merged_branches do |branch|
        printer.branch_info(branch_row(branch))
        true
      end

      if deleted_branches.empty?
        printer.no_branches_deleted
      else
        printer.done
      end
    end
    default_task :snip

    private

    def dry_run
      cleaner = GitSnip::Cleaner.new(*cleaner_args)

      printer.will_delete_branches

      merged_branches = cleaner.merged_branches

      merged_branches.each do |branch|
        printer.branch_info(branch_row(branch))
      end

      if merged_branches.any?
        printer.done
      else
        printer.no_branches_to_delete
      end
    end

    def cleaner_args
      opts.values_at(:repo, :target, :ignore)
    end

    def opts
      @opts ||= Options.merge(options, Config.new(options[:repo]).options)
    end

    def printer
      @printer ||= Printer.new(self)
    end

    def branch_row(branch)
      opts[:full] ? Branch.full_row(branch) : Branch.row(branch)
    end
  end
end
