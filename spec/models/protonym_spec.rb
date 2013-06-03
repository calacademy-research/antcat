# coding: UTF-8
require 'spec_helper'

describe Protonym do

  it "has an authorship" do
    authorship = FactoryGirl.create :citation
    protonym = Protonym.create! name: FactoryGirl.create(:name, name: 'Protonym'), authorship: authorship
    Protonym.find(protonym).authorship.should == authorship
  end

  describe "Authorship string" do
    it "should handle it if there is no citation" do
      protonym = FactoryGirl.build_stubbed :protonym, authorship: nil
      protonym.authorship_string.should be_nil
    end
    it "should delegate to the citation" do
      citation = FactoryGirl.build_stubbed :citation
      protonym = FactoryGirl.build_stubbed :protonym, authorship: citation
      citation.should_receive(:authorship_string).and_return 'Bolton 2005'
      protonym.authorship_string.should == 'Bolton 2005'
    end
  end

  describe "Importing" do
    before do @reference = FactoryGirl.create :article_reference, bolton_key_cache: 'Latreille 1809' end

    it "should create the Protonym and the Citation, which is linked to an existing Reference" do
      data = {
        family_or_subfamily_name: "Formicariae",
        sic: true,
        fossil: true,
        locality: 'U.S.A.',
        authorship: [{author_names: ["Latreille"], year: "1809", pages: "124", forms: 'w.q.'}],
      }

      protonym = Protonym.find Protonym.import(data)
      protonym.name.rank.should == 'family_or_subfamily'
      protonym.name.to_s.should == 'Formicariae'
      protonym.authorship.pages.should == '124'
      protonym.authorship.reference.should == @reference
      protonym.authorship.forms.should == 'w.q.'
      protonym.fossil.should be_true
      protonym.sic.should be_true
      protonym.locality.should == 'U.S.A.'
    end

    it "should handle a tribe protonym" do
      data = {tribe_name: "Aneuretini", authorship: [{author_names: ["Latreille"], year: "1809", pages: "124"}]}
      protonym = Protonym.find Protonym.import(data)
      protonym.name.rank.should == 'tribe'
      protonym.name.to_s.should == 'Aneuretini'
    end

    it "should handle a subtribe protonym" do
      data = {subtribe_name: 'Bothriomyrmecina', authorship: [{author_names: ["Latreille"], year: "1809", pages: "124"}]}
      protonym = Protonym.find Protonym.import(data)
      protonym.name.rank.should == 'subtribe'
      protonym.name.to_s.should == 'Bothriomyrmecina'
    end

    it "should handle a genus protonym" do
      data = {genus_name: "Atta", authorship: [{author_names: ["Latreille"], year: "1809", pages: "124"}]}
      protonym = Protonym.find Protonym.import(data)
      protonym.name.rank.should == 'genus'
      protonym.name.to_s.should == 'Atta'
    end

    it "should handle a species protonym" do
      data = {genus_name: "Heteromyrmex", species_epithet: 'atopogaster', authorship: [{author_names: ["Latreille"], year: "1809", pages: "124"}]}
      protonym = Protonym.find Protonym.import(data)
      protonym.name.rank.should == 'species'
      protonym.name.to_s.should == 'Heteromyrmex atopogaster'
    end

  end

  describe "Updating" do
    before do
      reference = FactoryGirl.create :article_reference,
        author_names: [FactoryGirl.create(:author_name, name: "Latreille")],
        citation_year: '1809', bolton_key_cache: 'Latreille 1809'
      @citation = Citation.create! reference: reference, pages: '12'
      @protonym = Protonym.create!(
        name:         Name.import(family_or_subfamily_name: 'Formicariae'),
        sic:          false,
        fossil:       false,
        authorship:   @citation,
        locality:     'CANADA'
      )
      @data = {
        family_or_subfamily_name: "Formicariae",
        sic: false,
        fossil: false,
        authorship: [{author_names: ["Latreille"], year: "1809", pages: '12'}],
        locality: 'CANADA',
      }
    end

    it "should compare, update and record changes to value fields" do
      data = @data.merge sic: true, fossil: true, locality: 'U.S.A.'
      @protonym.update_data data
      Update.count.should == 3

      update = Update.find_by_field_name 'sic'
      update.class_name.should == 'Protonym'
      update.field_name.should == 'sic'
      update.record_id.should == @protonym.id
      update.before.should == '0'
      update.after.should == '1'
      @protonym.reload.sic.should be_true

      update = Update.find_by_field_name 'fossil'
      update.class_name.should == 'Protonym'
      update.field_name.should == 'fossil'
      update.record_id.should == @protonym.id
      update.before.should == '0'
      update.after.should == '1'
      @protonym.reload.fossil.should be_true

      update = Update.find_by_field_name 'locality'
      update.class_name.should == 'Protonym'
      update.field_name.should == 'locality'
      update.record_id.should == @protonym.id
      update.before.should == 'CANADA'
      update.after.should == 'U.S.A.'
      @protonym.reload.locality.should == 'U.S.A.'

    end

    it "should compare Citations" do
      data = @data.dup
      data[:authorship][0][:pages] = '36'
      @protonym.update_data data
      Update.count.should == 1
    end
  end

  describe "Cascading delete" do
    it "should delete the citation when the protonym is deleted" do
      protonym = FactoryGirl.create :protonym
      Protonym.count.should == 1
      Citation.count.should == 1

      protonym.destroy

      Protonym.count.should be_zero
      Citation.count.should be_zero
    end
  end

  describe "Versioning" do
    it "should record versions" do
      with_versioning do
        protonym = FactoryGirl.create :protonym
        protonym.versions.last.event.should == 'create'
      end
    end
  end

end
