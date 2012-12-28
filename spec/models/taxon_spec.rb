# coding: UTF-8
require 'spec_helper'

describe Taxon do
  it "should require a name" do
    Factory.build(:taxon, name: nil).should_not be_valid
    taxon = FactoryGirl.create :taxon, name: FactoryGirl.create(:name, name: 'Cerapachynae')
    taxon.name.to_s.should == 'Cerapachynae'
    taxon.should be_valid
  end
  it "should be (Rails) valid with a nil status" do
    FactoryGirl.build(:taxon).should be_valid
    FactoryGirl.build(:taxon, status: 'valid').should be_valid
  end
  it "when status 'valid', should not be invalid" do
    taxon = FactoryGirl.build :taxon
    taxon.should_not be_invalid
  end
  it "should be able to be unidentifiable" do
    taxon = FactoryGirl.build :taxon
    taxon.should_not be_unidentifiable
    taxon.update_attribute :status, 'unidentifiable'
    taxon.should be_unidentifiable
    taxon.should be_invalid
  end
  it "should be able to be a collective group name" do
    taxon = FactoryGirl.build :taxon
    taxon.should_not be_collective_group_name
    taxon.update_attribute :status, 'collective group name'
    taxon.should be_collective_group_name
    taxon.should be_invalid
  end
  it "should be able to be an ichnotaxon" do
    taxon = FactoryGirl.build :taxon
    taxon.should_not be_ichnotaxon
    taxon.update_attribute :status, 'ichnotaxon'
    taxon.should be_ichnotaxon
    taxon.should be_invalid
  end
  it "should be able to be unavailable" do
    taxon = FactoryGirl.build :taxon
    taxon.should_not be_unavailable
    taxon.should be_available
    taxon.update_attribute :status, 'unavailable'
    taxon.should be_unavailable
    taxon.should_not be_available
    taxon.should be_invalid
  end
  it "should be able to be excluded" do
    taxon = FactoryGirl.build :taxon
    taxon.should_not be_excluded
    taxon.update_attribute :status, 'excluded'
    taxon.should be_excluded
    taxon.should be_invalid
  end
  it "should be able to be a synonym" do
    taxon = FactoryGirl.build :taxon
    taxon.should_not be_synonym
    taxon.update_attribute :status, 'synonym'
    taxon.should be_synonym
    taxon.should be_invalid
  end
  it "should be able to be a fossil" do
    taxon = FactoryGirl.build :taxon
    taxon.should_not be_fossil
    taxon.fossil.should == false
    taxon.update_attribute :fossil, true
    taxon.should be_fossil
  end
  it "should raise if anyone calls #children directly" do
    lambda {Taxon.new.children}.should raise_error NotImplementedError
  end
  it "should be able to be a homonym of something else" do
    neivamyrmex = FactoryGirl.create :taxon
    acamatus = FactoryGirl.create :taxon, status: 'homonym', homonym_replaced_by: neivamyrmex
    acamatus.reload
    acamatus.should be_homonym
    acamatus.homonym_replaced_by.should == neivamyrmex
  end
  it "should be able to have an incertae_sedis_in" do
    myanmyrma = FactoryGirl.create :taxon, incertae_sedis_in: 'family'
    myanmyrma.reload
    myanmyrma.incertae_sedis_in.should == 'family'
    myanmyrma.should_not be_invalid
  end
  it "should be able to say whether it is incertae sedis in a particular rank" do
    myanmyrma = FactoryGirl.create :taxon, incertae_sedis_in: 'family'
    myanmyrma.reload
    myanmyrma.should be_incertae_sedis_in('family')
  end

  describe "Find by name" do
    it "should return nil if nothing matches" do
      Taxon.find_by_name('sdfsdf').should == nil
    end
    it "should return one of the items if there are more than one (bad!)" do
      name = FactoryGirl.create :genus_name, name: 'Monomorium'
      2.times {FactoryGirl.create :genus, name: name}
      Taxon.find_by_name('Monomorium').name.name.should == 'Monomorium'
    end
  end

  describe "Find by epithet" do
    it "should return nil if nothing matches" do
      Taxon.find_by_epithet('sdfsdf').should be_empty
    end
    it "should return all the items if there is more than one" do
      FactoryGirl.create :species, name: FactoryGirl.create(:species_name, name: 'Monomorium alta', epithet: 'alta')
      FactoryGirl.create :species, name: FactoryGirl.create(:species_name, name: 'Atta alta', epithet: 'alta')
      Taxon.find_by_epithet('alta').map(&:name).map(&:to_s).should =~ ['Monomorium alta', 'Atta alta']
    end
  end

  describe "Find an epithet in a genus" do
    it "should return nil if nothing matches" do
      Taxon.find_epithet_in_genus('sdfsdf', create_genus).should == nil
    end
    it "should return the one item" do
      species = create_species 'Atta serratula'
      Taxon.find_epithet_in_genus('serratula', species.genus).should == [species]
    end
    describe "Finding mandatory spelling changes" do
      it "should find -a when asked to find -us" do
        species = create_species 'Atta serratula'
        Taxon.find_epithet_in_genus('serratulus', species.genus).should == [species]
      end
    end
  end

  describe "Find name" do
    before do
      FactoryGirl.create :genus, name: FactoryGirl.create(:genus_name, name: 'Monomorium')
      @monoceros = FactoryGirl.create :genus, name: FactoryGirl.create(:genus_name, name: 'Monoceros')
      species_name = FactoryGirl.create(:species_name, name: 'Monoceros rufa', epithet: 'rufa')
      @rufa = FactoryGirl.create :species, genus: @monoceros, name: species_name
    end
    it "should return [] if nothing matches" do
      Taxon.find_name('sdfsdf').should == []
    end
    it "should return an exact match" do
      Taxon.find_name('Monomorium').first.name.to_s.should == 'Monomorium'
    end
    it "should return a prefix match" do
      Taxon.find_name('Monomor', 'beginning with').first.name.to_s.should == 'Monomorium'
    end
    it "should return a substring match" do
      Taxon.find_name('iu', 'containing').first.name.to_s.should == 'Monomorium'
    end
    it "should return multiple matches" do
      results = Taxon.find_name('Mono', 'containing')
      results.size.should == 2
    end
    it "should not return anything but subfamilies, tribes, genera, subgenera, species,and subspecies" do
      create_subfamily 'Lepto'
      create_tribe 'Lepto1'
      create_genus 'Lepto2'
      create_subgenus 'Lepto3'
      create_species 'Lepto4'
      create_subspecies 'Lepto5'
      results = Taxon.find_name 'Lepto', 'beginning with'
      results.size.should == 6
    end
    it "should sort results by name" do
      FactoryGirl.create :subfamily, name: FactoryGirl.create(:name, name: 'Lepti')
      FactoryGirl.create :subfamily, name: FactoryGirl.create(:name, name: 'Lepta')
      FactoryGirl.create :subfamily, name: FactoryGirl.create(:name, name: 'Lepte')
      results = Taxon.find_name 'Lept', 'beginning with'
      results.map(&:name).map(&:to_s).should == ['Lepta', 'Lepte', 'Lepti']
    end

    describe "Finding full species name" do
      it "should search for full species name" do
        results = Taxon.find_name 'Monoceros rufa '
        results.first.should == @rufa
      end
      it "should search for whole name, even when using beginning with, even with trailing space" do
        results = Taxon.find_name 'Monoceros rufa ', 'beginning with'
        results.first.should == @rufa
      end
      it "should search for partial species name" do
        results = Taxon.find_name 'Monoceros ruf', 'beginning with'
        results.first.should == @rufa
      end
    end
  end

  describe ".rank" do
    it "should return a lowercase version" do
      FactoryGirl.create(:subfamily).name.rank.should == 'subfamily'
    end
  end

  describe "being a synonym of" do
    it "should not think it's a synonym of something when it's not" do
      genus = FactoryGirl.create :genus
      another_genus = FactoryGirl.create :genus
      genus.should_not be_synonym_of another_genus
    end
    it "should think it's a synonym of something when it is" do
      senior = FactoryGirl.create :genus
      junior = create_synonym senior
      junior.should be_synonym_of senior
    end
  end

  describe "being a homonym replaced by something" do
    it "should not think it's a homonym replaced by something when it's not" do
      genus = FactoryGirl.create :genus
      another_genus = FactoryGirl.create :genus
      genus.should_not be_homonym_replaced_by another_genus
      genus.homonym_replaced.should be_nil
    end
    it "should think it's a homonym replaced by something when it is" do
      replacement = FactoryGirl.create :genus
      homonym = FactoryGirl.create :genus, homonym_replaced_by: replacement, status: 'homonym'
      homonym.should be_homonym_replaced_by replacement
      replacement.homonym_replaced.should == homonym
    end
  end

  describe "the 'valid' scope" do
    it "should only include valid taxa" do
      subfamily = FactoryGirl.create :subfamily
      replacement = FactoryGirl.create :genus, subfamily: subfamily
      homonym = FactoryGirl.create :genus, homonym_replaced_by: replacement, status: 'homonym', subfamily: subfamily
      synonym = create_synonym replacement, subfamily: subfamily
      subfamily.genera.valid.should == [replacement]
    end
  end

  describe "the 'extant' scope" do
    it "should only include extant taxa" do
      subfamily = FactoryGirl.create :subfamily
      extant_genus = FactoryGirl.create :genus, subfamily: subfamily
      FactoryGirl.create :genus, subfamily: subfamily, fossil: true
      subfamily.genera.extant.should == [extant_genus]
    end
  end

  describe "ordered by name" do
    it "should order by name" do
      zymacros = FactoryGirl.create :subfamily, name: FactoryGirl.create(:name, name: 'Zymacros')
      atta = FactoryGirl.create :subfamily, name: FactoryGirl.create(:name, name: 'Atta')
      Taxon.ordered_by_name.should == [atta, zymacros]
    end
  end

  describe "Protonym" do
    it "should have a protonym" do
      taxon = Family.new
      taxon.protonym.should be_nil
      taxon.build_protonym name: FactoryGirl.create(:name, name: 'Formicariae')
    end
  end

  describe "Type name" do
    it "should have a type name" do
      taxon = FactoryGirl.create :family
      taxon.type_name = FactoryGirl.create(:family_name, name: 'Formicariae')
      taxon.save!
      taxon = Taxon.find taxon
      taxon.type_name.to_s.should == 'Formicariae'
      taxon.type_name.rank.should == 'family'
    end
    it "should not be required" do
      taxon = FactoryGirl.create :family, type_name: nil
      taxon.should be_valid
    end
  end

  describe "Taxonomic history items" do
    it "should have some" do
      taxon = FactoryGirl.create :family
      taxon.history_items.should be_empty
      taxon.history_items.create! taxt: 'foo'
      taxon.reload.history_items.map(&:taxt).should == ['foo']
    end
    it "should show the items in the order in which they were added to the taxon" do
      taxon = FactoryGirl.create :family
      taxon.history_items.create! taxt: '1'
      taxon.history_items.create! taxt: '2'
      taxon.history_items.create! taxt: '3'
      taxon.history_items.map(&:taxt).should == ['1','2','3']
      taxon.history_items.first.move_to_bottom
      taxon.history_items(true).map(&:taxt).should == ['2','3','1']
    end
  end

  describe "Reference sections" do
    it "should have some" do
      taxon = FactoryGirl.create :family
      taxon.reference_sections.should be_empty
      taxon.reference_sections.create! references: 'foo'
      taxon.reload.reference_sections.map(&:references).should == ['foo']
    end
    it "should show the items in the order in which they were added to the taxon" do
      taxon = FactoryGirl.create :family
      taxon.reference_sections.create! references: '1'
      taxon.reference_sections.create! references: '2'
      taxon.reference_sections.create! references: '3'
      taxon.reference_sections.map(&:references).should == ['1','2','3']
      taxon.reference_sections.first.move_to_bottom
      taxon.reference_sections(true).map(&:references).should == ['2','3','1']
    end
  end

  describe "Child list queries" do
    before do
      @subfamily = FactoryGirl.create :subfamily, name: FactoryGirl.create(:name, name: 'Dolichoderinae')
    end
    it "should find all genera for the taxon if there are no conditions" do
      FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Atta'), subfamily: @subfamily
      FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Eciton'), subfamily: @subfamily, fossil: true
      FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Aneuretus'), subfamily: @subfamily, fossil: true, incertae_sedis_in: 'subfamily'
      @subfamily.child_list_query(:genera).map(&:name).map(&:to_s).sort.should == ['Aneuretus', 'Atta', 'Eciton']
      @subfamily.child_list_query(:genera, fossil: true).map(&:name).map(&:to_s).sort.should == ['Aneuretus', 'Eciton']
      @subfamily.child_list_query(:genera, incertae_sedis_in: 'subfamily').map(&:name).map(&:to_s).sort.should == ['Aneuretus']
    end
    it "should not include invalid taxa" do
      FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Atta'), subfamily: @subfamily, status: 'synonym'
      FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Eciton'), subfamily: @subfamily, fossil: true
      FactoryGirl.create :genus, name: FactoryGirl.create(:name, name: 'Aneuretus'), subfamily: @subfamily, fossil: true, incertae_sedis_in: 'subfamily'
      @subfamily.child_list_query(:genera).map(&:name).map(&:to_s).sort.should == ['Aneuretus', 'Eciton']
    end
  end

  describe "Cascading delete" do
    it "should delete the protonym when the taxon is deleted" do
      Taxon.count.should be_zero
      Protonym.count.should be_zero

      genus = FactoryGirl.create :genus, tribe: nil, subfamily: nil
      Taxon.count.should == 1
      Protonym.count.should == 1

      genus.destroy
      Taxon.count.should be_zero
      Protonym.count.should be_zero
    end
    it "should delete history and reference sections when the taxon is deleted" do
      Taxon.count.should be_zero
      ReferenceSection.count.should be_zero

      genus = FactoryGirl.create :genus, tribe: nil, subfamily: nil
      genus.reference_sections.create! title: 'title', references: 'references'
      ReferenceSection.count.should == 1

      genus.destroy
      ReferenceSection.count.should be_zero
    end
  end

  describe "Synonyms" do
    it "should have junior and senior synonyms" do
      senior = create_genus 'Atta'
      junior = create_genus 'Eciton'
      Synonym.create! junior_synonym: junior, senior_synonym: senior
      senior.should have(1).junior_synonym
      senior.should have(0).senior_synonyms
      junior.should have(1).senior_synonym
      junior.should have(0).junior_synonyms
    end

    describe "Reversing synonymy" do
      it "should make one the synonym of the other and set statuses" do
        atta = create_genus 'Atta'
        attaboi = create_genus 'Attaboi'

        atta.become_junior_synonym_of attaboi
        atta.reload; attaboi.reload
        atta.should be_synonym_of attaboi

        attaboi.become_junior_synonym_of atta
        atta.reload; attaboi.reload
        attaboi.status.should == 'synonym'
        attaboi.should be_synonym_of atta
        atta.status.should == 'valid'
        atta.should_not be_synonym_of attaboi
      end

      it "should not create duplicate synonym in case of synonym cycle" do
        atta = create_genus 'Atta', status: 'synonym'
        attaboi = create_genus 'Attaboi', status: 'synonym'
        Synonym.create! junior_synonym: atta, senior_synonym: attaboi
        Synonym.create! junior_synonym: attaboi, senior_synonym: atta
        Synonym.count.should == 2

        atta.become_junior_synonym_of attaboi
        Synonym.count.should == 1
        atta.should be_synonym_of attaboi
        attaboi.should_not be_synonym_of atta
      end
    end

    describe "Removing synonymy" do
      it "should remove all synonymies for the taxon" do
        atta = create_genus 'Atta'
        attaboi = create_genus 'Attaboi'
        attaboi.become_junior_synonym_of atta
        atta.junior_synonyms.all.include?(attaboi).should be_true
        atta.should_not be_synonym
        attaboi.should be_synonym
        attaboi.senior_synonyms.all.include?(atta).should be_true

        attaboi.become_not_a_junior_synonym_of atta

        atta.junior_synonyms.all.include?(attaboi).should be_false
        atta.should_not be_synonym
        attaboi.should_not be_synonym
        attaboi.senior_synonyms.all.include?(atta).should be_false
      end
    end

  end

end
