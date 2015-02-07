require 'git_snip/branch'

RSpec.describe GitSnip::Branch do
  it 'should return values with number of characters within 80' do
    column = described_class::Column.new
    column.sha = '28720606978a7257f735ce67df50bc55ccf1c138'
    column.name = 'a_pretty_long_branch_name'
    column.author = 'inigo_montoya@example.com'
    column.date = Time.now
    column.message = 'Hello, my name is Inigo Montoya.'

    result = described_class.columnize(build_branch(column))

    expect([
      result.sha, result.name, result.author, result.date, result.message
    ].join(' ').size).to eq(80)
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
end
