require 'git_snip/printer'

RSpec.describe GitSnip::Printer do
  [
    [:force_option_needed, '-f option is needed to delete branches.', :red],
    [:deleting_branches, "Deleting the following branches...\n\n", :green],
    [:no_branches_deleted, 'No branches were deleted.', :green],
    [:will_delete_branches, "Would delete the following branches...\n\n", :green],
    [:no_branches_to_delete, 'No branches would be deleted.', :green],
    [:done, "\nDone.", :green]
  ].each do |method, text, color|
    describe "##{method}" do
      let(:sayer) { spy('sayer') }
      let(:printer) { described_class.new(sayer) }

      it "should print #{text.inspect} in #{color}" do
        printer.send(method)
        expect(sayer).to have_received(:say).with(text, color)
      end
    end
  end

  describe '#branch_info' do
    let(:sayer) { spy('sayer') }
    let(:printer) { described_class.new(sayer) }

    it 'should print a row of branch info' do
      printer.branch_info(row_double)

      expect(sayer).to have_received(:say).with('sha ', :yellow).ordered
      expect(sayer).to have_received(:say).with('name ', :magenta).ordered
      expect(sayer).to have_received(:say).with('date ', :green).ordered
      expect(sayer).to have_received(:say).with('author ', [:blue, :bold]).ordered
      expect(sayer).to have_received(:say).with("hello world\n").ordered
    end

    it 'should strip the last row and append new line' do
      printer.branch_info(row_double(message: " hello world \n\n\n"))

      expect(sayer).to have_received(:say).with("hello world\n")
    end

    def row_double(attrs = {})
      instance_double('GitSnip::Branch::Row', {
        sha: 'sha',
        name: 'name',
        date: 'date',
        author: 'author',
        message: 'hello world'
      }.merge(attrs))
    end
  end
end
