require 'spec_helper'

describe Journal do
  describe "importing from a new record" do
    it "should create and return the journal" do
      expect(Journal.import(:name => 'Antucopia').name).to include('Antucopia')
    end

    it "should raise on invalid input" do
      expect {Journal.import(:name => '')}.to raise_error
    end

    it "should reuse an existing journal" do
      Journal.import(:name => 'Antucopia')
      Journal.import(:name => 'Antucopia')
      expect(Journal.count).to eq(1)
    end
  end

  describe "searching" do
    it "should do fuzzy matching of journal names" do
      FactoryGirl.create(:journal, :name => 'American Bibliographic Proceedings')
      FactoryGirl.create(:journal, :name => 'Playboy')
      expect(Journal.search('ABP')).to eq(['American Bibliographic Proceedings'])
    end

    it "should require matching the first letter" do
      FactoryGirl.create(:journal, :name => 'ABC')
      expect(Journal.search('BC')).to eq([])
    end

    it "should return results in order of most used" do
      ['Most Used', 'Never Used', 'Occasionally Used', 'Rarely Used'].each do |name|
        FactoryGirl.create :journal, :name => name
      end
      2.times {FactoryGirl.create :article_reference, :journal => Journal.find_by_name('Rarely Used')}
      3.times {FactoryGirl.create :article_reference, :journal => Journal.find_by_name('Occasionally Used')}
      4.times {FactoryGirl.create :article_reference, :journal => Journal.find_by_name('Most Used')}
      0.times {FactoryGirl.create :article_reference, :journal => Journal.find_by_name('Never Used')}

      expect(Journal.search).to eq(['Most Used', 'Occasionally Used', 'Rarely Used', 'Never Used'])
    end
  end

  describe 'validation' do
    it 'should require a name' do
      expect(Journal.new).not_to be_valid
      expect(Journal.new(:name => 'name')).to be_valid
    end
  end

  describe "Versioning" do
    it "should record versions" do
      with_versioning do
        journal = FactoryGirl.create :journal
        expect(journal.versions.last.event).to eq('create')
      end
    end
  end

end
