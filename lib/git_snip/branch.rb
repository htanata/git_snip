module GitSnip
  module Branch
    class Column < Struct.new(:sha, :name, :date, :author, :message)
    end

    def self.columnize(branch)
      Column.new.tap do |column|
        column.sha = column(branch.gcommit.sha, 7)
        column.name = column(branch.name, 12)
        column.date = column(branch.gcommit.date.strftime('%F'), 10)
        column.author = column(branch.gcommit.author.email.sub(/@.*/, ''), 8)
        column.message = column(branch.gcommit.message, 39)
      end
    end

    private

    def self.column(string, width)
      string[0, width].ljust(width)
    end
  end
end
