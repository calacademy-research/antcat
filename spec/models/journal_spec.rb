require 'spec_helper'

describe Journal do
  it { should be_versioned }
  it { should validate_presence_of :name }

  describe ".search" do
    it "should do fuzzy matching of journal names" do
      create :journal, name: 'American Bibliographic Proceedings'
      create :journal, name: 'Playboy'
      expect(Journal.search('ABP')).to eq ['American Bibliographic Proceedings']
    end

    it "requires matching the first letter" do
      create :journal, name: 'ABC'
      expect(Journal.search('BC')).to eq []
    end

    it "returns results in order of most used" do
      ['Most Used', 'Never Used', 'Occasionally Used', 'Rarely Used'].each do |name|
        create :journal, name: name
      end
      2.times { create :article_reference, journal: Journal.find_by(name: 'Rarely Used') }
      3.times { create :article_reference, journal: Journal.find_by(name: 'Occasionally Used') }
      4.times { create :article_reference, journal: Journal.find_by(name: 'Most Used') }
      0.times { create :article_reference, journal: Journal.find_by(name: 'Never Used') }

      expect(Journal.search).to eq ['Most Used', 'Occasionally Used', 'Rarely Used', 'Never Used']
    end
  end

  describe "#destroy" do
    let!(:journal) { create :journal, name: "ABC" }

    context "journal without references" do
      it "should work" do
        expect { journal.destroy }.to change { Journal.count }.from(1).to(0)
      end
    end

    context "journal with a reference" do
      it "should not work" do
        create :article_reference, journal: journal
        expect { journal.destroy }.not_to change { Journal.count }
        expect(journal.errors[:base]).to eq ["cannot delete journal (not unused)"]
      end
    end
  end
end
