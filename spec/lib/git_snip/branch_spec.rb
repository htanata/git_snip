require 'git_snip/branch'

RSpec.describe GitSnip::Branch do
  it 'should return values with number of characters within 80' do
    result = described_class.columnize(build_branch(build_column))

    expect([
      result.sha, result.name, result.author, result.date, result.message
    ].join(' ').size).to eq(80)
  end

  it 'should remove message starting from the first new line' do
    column = build_column(message: "First line\n\nThird line")
    result = described_class.columnize(build_branch(column))

    expect(result.message).to eq('First line' + (' ' * 29))
  end

  def build_branch(column)
    author = instance_double('Git::Author', email: column.author)

    gcommit = instance_double(
      'Git::Gcommit',
      sha: column.sha,
      date: column.date,
      message: column.message,
      author: author
    )

    instance_double('Git::Branch', name: column.name, gcommit: gcommit)
  end

  def build_column(attrs = {})
    described_class::Column.new.tap do |column|
      column.sha = attrs[:sha] || '28720606978a7257f735ce67df50bc55ccf1c138'
      column.name = attrs[:name] || 'a_pretty_long_branch_name'
      column.author = attrs[:author] || 'inigo_montoya@example.com'
      column.date = attrs[:date] || Time.now
      column.message = attrs[:message] || 'Hello, my name is Inigo Montoya.'
    end
  end

end
