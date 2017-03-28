# frozen_string_literal: true

module GitSnip
  module Branch
    Row = Struct.new(:sha, :name, :date, :author, :message)

    class << self
      def row(branch)
        Row.new.tap do |row|
          row.sha = column(branch.gcommit.sha, 7)
          row.name = column(branch.name, 12)
          row.date = column(branch.gcommit.date.strftime('%F'), 10)
          row.author = column(branch.gcommit.author.email.sub(/@.*/, ''), 8)
          row.message = column(first_line(branch.gcommit.message), 39)
        end
      end

      def full_row(branch)
        Row.new.tap do |row|
          row.sha = branch.gcommit.sha
          row.name = branch.name
          row.date = branch.gcommit.date.iso8601
          row.author = branch.gcommit.author.email
          row.message = first_line(branch.gcommit.message)
        end
      end

      private

      def column(string, width)
        string[0, width].ljust(width)
      end

      def first_line(string)
        string.gsub(/[\r\n].*/, '')
      end
    end
  end
end
