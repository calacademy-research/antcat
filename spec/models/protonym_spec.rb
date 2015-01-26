# coding: UTF-8
require 'spec_helper'

describe Protonym do

  describe "Authorship" do
    it "has an authorship" do
      authorship = FactoryGirl.create :citation
      protonym = Protonym.create! name: FactoryGirl.create(:name, name: 'Protonym'), authorship: authorship
      expect(Protonym.find(protonym).authorship).to eq(authorship)
    end
    it "requires an authorship" do
      protonym = Protonym.new name: FactoryGirl.create(:name, name: 'Protonym')
      expect(protonym).not_to be_valid
      protonym.update_attribute :authorship, FactoryGirl.create(:citation)
      expect(protonym).to be_valid
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

  describe "Orphans" do
    it "should delete the orphaned protonym(s) when the taxon is deleted" do
      genus = create_genus
      original_protonym_count = Protonym.count

      orphan_protonym = FactoryGirl.create :protonym
      expect(Protonym.count).to eq(original_protonym_count + 1)

      Protonym.destroy_orphans

      expect(Protonym.count).to eq(original_protonym_count)
      expect(Protonym.all).not_to include(orphan_protonym)
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
      expect(protonym.name.rank).to eq('family_or_subfamily')
      expect(protonym.name.to_s).to eq('Formicariae')
      expect(protonym.authorship.pages).to eq('124')
      expect(protonym.authorship.reference).to eq(@reference)
      expect(protonym.authorship.forms).to eq('w.q.')
      expect(protonym.fossil).to be_truthy
      expect(protonym.sic).to be_truthy
      expect(protonym.locality).to eq('U.S.A.')
    end

    it "should handle a tribe protonym" do
      data = {tribe_name: "Aneuretini", authorship: [{author_names: ["Latreille"], year: "1809", pages: "124"}]}
      protonym = Protonym.find Protonym.import(data)
      expect(protonym.name.rank).to eq('tribe')
      expect(protonym.name.to_s).to eq('Aneuretini')
    end

    it "should handle a subtribe protonym" do
      data = {subtribe_name: 'Bothriomyrmecina', authorship: [{author_names: ["Latreille"], year: "1809", pages: "124"}]}
      protonym = Protonym.find Protonym.import(data)
      expect(protonym.name.rank).to eq('subtribe')
      expect(protonym.name.to_s).to eq('Bothriomyrmecina')
    end

    it "should handle a genus protonym" do
      data = {genus_name: "Atta", authorship: [{author_names: ["Latreille"], year: "1809", pages: "124"}]}
      protonym = Protonym.find Protonym.import(data)
      expect(protonym.name.rank).to eq('genus')
      expect(protonym.name.to_s).to eq('Atta')
    end

    it "should handle a species protonym" do
      data = {genus_name: "Heteromyrmex", species_epithet: 'atopogaster', authorship: [{author_names: ["Latreille"], year: "1809", pages: "124"}]}
      protonym = Protonym.find Protonym.import(data)
      expect(protonym.name.rank).to eq('species')
      expect(protonym.name.to_s).to eq('Heteromyrmex atopogaster')
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
      expect(Update.count).to eq(3)

      update = Update.find_by_field_name 'sic'
      expect(update.class_name).to eq('Protonym')
      expect(update.field_name).to eq('sic')
      expect(update.record_id).to eq(@protonym.id)
      expect(update.before).to eq('0')
      expect(update.after).to eq('1')
      expect(@protonym.reload.sic).to be_truthy

      update = Update.find_by_field_name 'fossil'
      expect(update.class_name).to eq('Protonym')
      expect(update.field_name).to eq('fossil')
      expect(update.record_id).to eq(@protonym.id)
      expect(update.before).to eq('0')
      expect(update.after).to eq('1')
      expect(@protonym.reload.fossil).to be_truthy

      update = Update.find_by_field_name 'locality'
      expect(update.class_name).to eq('Protonym')
      expect(update.field_name).to eq('locality')
      expect(update.record_id).to eq(@protonym.id)
      expect(update.before).to eq('CANADA')
      expect(update.after).to eq('U.S.A.')
      expect(@protonym.reload.locality).to eq('U.S.A.')

    end

    it "should compare Citations" do
      data = @data.dup
      data[:authorship][0][:pages] = '36'
      @protonym.update_data data
      expect(Update.count).to eq(1)
    end
  end

end
