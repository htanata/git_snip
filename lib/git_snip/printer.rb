# frozen_string_literal: true

module GitSnip
  class Printer
    def initialize(cli)
      @cli = cli
    end

    def force_option_needed
      @cli.say '-f option is needed to delete branches.', :red
    end

    def deleting_branches
      @cli.say "Deleting the following branches...\n\n", :green
    end

    def no_branches_deleted
      @cli.say 'No branches were deleted.', :green
    end

    def will_delete_branches
      @cli.say "Would delete the following branches...\n\n", :green
    end

    def no_branches_to_delete
      @cli.say 'No branches would be deleted.', :green
    end

    def done
      @cli.say "\nDone.", :green
    end

    def branch_info(row)
      @cli.say row.sha + ' ', :yellow
      @cli.say row.name + ' ', :magenta
      @cli.say row.date + ' ', :green
      @cli.say row.author + ' ', [:blue, :bold]
      @cli.say row.message.strip + "\n"
    end
  end
end
