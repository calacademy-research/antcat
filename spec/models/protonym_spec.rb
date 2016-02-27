require 'spec_helper'

describe Protonym do

  it { should validate_presence_of(:authorship) }

  describe "Authorship" do
    it "has an authorship" do
      authorship = FactoryGirl.create :citation
      protonym = Protonym.create! name: FactoryGirl.create(:name, name: 'Protonym'), authorship: authorship
      expect(Protonym.find(protonym.id).authorship).to eq(authorship)
    end
  end

  describe "Authorship string" do
    it "should handle it if there is no citation" do
      protonym = FactoryGirl.build_stubbed :protonym, authorship: nil
      expect(protonym.authorship_string).to be_nil
    end
    it "should delegate to the citation" do
      citation = FactoryGirl.build_stubbed :citation
      protonym = FactoryGirl.build_stubbed :protonym, authorship: citation
      expect(citation).to receive(:authorship_string).and_return 'Bolton 2005'
      expect(protonym.authorship_string).to eq('Bolton 2005')
    end
  end

  describe "Authorship HTML string" do
    it "should handle it if there is no citation" do
      protonym = FactoryGirl.build_stubbed :protonym, authorship: nil
      expect(protonym.authorship_html_string).to be_nil
    end
    it "should delegate to the citation" do
      citation = FactoryGirl.build_stubbed :citation
      protonym = FactoryGirl.build_stubbed :protonym, authorship: citation
      expect(citation).to receive(:authorship_html_string).and_return 'XYZ'
      expect(protonym.authorship_html_string).to eq('XYZ')
    end
  end

  describe "Last names string" do
    it "should handle it if there is no citation" do
      protonym = FactoryGirl.build_stubbed :protonym, authorship: nil
      expect(protonym.authorship_string).to be_nil
    end
    it "should delegate to the citation" do
      citation = FactoryGirl.build_stubbed :citation
      protonym = FactoryGirl.build_stubbed :protonym, authorship: citation
      expect(citation).to receive(:author_last_names_string).and_return 'Bolton'
      expect(protonym.author_last_names_string).to eq('Bolton')
    end
  end

  describe "Year" do
    it "should handle it if there is no citation" do
      protonym = FactoryGirl.build_stubbed :protonym, authorship: nil
      expect(protonym.year).to be_nil
    end
    it "should delegate to the citation" do
      citation = FactoryGirl.build_stubbed :citation
      protonym = FactoryGirl.build_stubbed :protonym, authorship: citation
      expect(citation).to receive(:year).and_return '2010'
      expect(protonym.year).to eq('2010')
    end
  end

  describe "Cascading delete" do
    it "should delete the citation when the protonym is deleted" do
      protonym = FactoryGirl.create :protonym
      expect(Protonym.count).to eq(1)
      expect(Citation.count).to eq(1)

      protonym.destroy

      expect(Protonym.count).to be_zero
      expect(Citation.count).to be_zero
    end
  end

  describe "Versioning" do
    it "should record versions" do
      with_versioning do
        protonym = FactoryGirl.create :protonym
        expect(protonym.versions.last.event).to eq('create')
      end
    end
  end
  
end
