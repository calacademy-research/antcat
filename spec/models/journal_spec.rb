require 'spec_helper'

describe Journal do
  it { is_expected.to be_versioned }
  it { is_expected.to validate_presence_of :name }

  describe "#destroy" do
    let!(:journal) { create :journal, name: "ABC" }

    context "journal without references" do
      it "works" do
        expect { journal.destroy }.to change { described_class.count }.from(1).to(0)
      end
    end

    context "journal with a reference" do
      it "doesn't work" do
        create :article_reference, journal: journal
        expect { journal.destroy }.not_to change { described_class.count }
        expect(journal.errors[:base]).to eq ["cannot delete journal (not unused)"]
      end
    end
  end
end
