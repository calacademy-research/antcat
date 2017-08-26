require 'spec_helper'

describe Journal do
  it { should be_versioned }
  it { should validate_presence_of :name }

  describe ".search" do
    it "fuzzy matches journal names" do
      create :journal, name: 'American Bibliographic Proceedings'
      create :journal, name: 'Playboy'
      expect(described_class.search('ABP')).to eq ['American Bibliographic Proceedings']
    end

    it "requires matching the first letter" do
      create :journal, name: 'ABC'
      expect(described_class.search('BC')).to eq []
    end

    it "returns results in order of most used" do
      ['Most Used', 'Never Used', 'Occasionally Used', 'Rarely Used'].each do |name|
        create :journal, name: name
      end
      2.times { create :article_reference, journal: described_class.find_by(name: 'Rarely Used') }
      3.times { create :article_reference, journal: described_class.find_by(name: 'Occasionally Used') }
      4.times { create :article_reference, journal: described_class.find_by(name: 'Most Used') }
      0.times { create :article_reference, journal: described_class.find_by(name: 'Never Used') }

      expect(described_class.search).to eq ['Most Used', 'Occasionally Used', 'Rarely Used', 'Never Used']
    end
  end

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
