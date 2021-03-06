# frozen_string_literal: true

require 'git_snip/branch'

RSpec.describe GitSnip::Branch do
  describe '.row' do
    it 'should return values with number of characters within 80' do
      result = described_class.row(build_branch(build_row))

      expect([
        result.sha, result.name, result.author, result.date, result.message
      ].join(' ').size).to eq(80)
    end

    it 'should remove message starting from the first new line' do
      row = build_row(message: "First line\n\nThird line")
      result = described_class.row(build_branch(row))

      expect(result.message).to eq('First line' + (' ' * 29))
    end
  end

  describe '.full_row' do
    it 'should return values while keeping most of the words' do
      row = build_row(
        message: ('A' * 100) + "\n\n" + ('B' * 85),
        author: 'would_you_kindly@example.com'
      )

      result = described_class.full_row(build_branch(row))

      expect(result.sha).to eq(row.sha)
      expect(result.name).to eq(row.name)
      expect(result.author).to eq(row.author)
      expect(result.date).to eq(row.date.iso8601)
      expect(result.message).to eq('A' * 100)
    end
  end

  def build_branch(row)
    author = instance_double('Git::Author', email: row.author)

    gcommit = instance_double(
      'Git::Gcommit',
      sha: row.sha,
      date: row.date,
      message: row.message,
      author: author
    )

    instance_double('Git::Branch', name: row.name, gcommit: gcommit)
  end

  def build_row(attrs = {})
    described_class::Row.new.tap do |row|
      row.sha = attrs[:sha] || '28720606978a7257f735ce67df50bc55ccf1c138'
      row.name = attrs[:name] || 'a_pretty_long_branch_name'
      row.author = attrs[:author] || 'inigo_montoya@example.com'
      row.date = attrs[:date] || Time.now
      row.message = attrs[:message] || 'Hello, my name is Inigo Montoya.'
    end
  end
end
