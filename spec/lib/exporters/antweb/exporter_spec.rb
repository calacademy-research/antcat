# coding: UTF-8
require 'spec_helper'

describe Exporters::Antweb::Exporter do
  before do
    @exporter = Exporters::Antweb::Exporter.new
    stub = double format: 'history'
    Exporters::Antweb::Formatter.stub(:new).and_return stub
  end

  describe "exporting one taxon" do
    before do
      @ponerinae = create_subfamily 'Ponerinae'
      @attini = create_tribe 'Attini', subfamily: @ponerinae
    end

    it "should export a subfamily" do
      create_genus subfamily: @ponerinae, tribe: nil
      @ponerinae.stub(:authorship_string).and_return('Bolton, 2011')
      @exporter.export_taxon(@ponerinae).should == ['Ponerinae', nil, nil, nil, 'Bolton, 2011', nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
    end

    it "should export fossil taxa" do
      create_genus subfamily: @ponerinae, tribe: nil
      fossil = create_genus 'Atta', subfamily: @ponerinae, tribe: nil, fossil: true
      @ponerinae.stub(:authorship_string).and_return 'Bolton, 2011'
      fossil.stub(:authorship_string).and_return 'Fisher, 2013'
      @exporter.export_taxon(@ponerinae).should == ['Ponerinae', nil, nil, nil, 'Bolton, 2011', nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
      @exporter.export_taxon(fossil).should == ['Ponerinae', nil, 'Atta', nil, 'Fisher, 2013', nil, 'TRUE', 'TRUE', nil, nil, 'TRUE', 'history']
    end

    it "should export a genus" do
      dacetini = create_tribe 'Dacetini', subfamily: @ponerinae
      acanthognathus = create_genus 'Acanothognathus', subfamily: @ponerinae, tribe: dacetini
      acanthognathus.stub(:authorship_string).and_return 'Bolton, 2011'
      @exporter.export_taxon(acanthognathus).should == ['Ponerinae', 'Dacetini', 'Acanothognathus', nil, 'Bolton, 2011', nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
    end

    it "should export a genus without a tribe" do
      acanthognathus = create_genus 'Acanothognathus', subfamily: @ponerinae, tribe: nil
      acanthognathus.stub(:authorship_string).and_return 'Bolton, 2011'
      @exporter.export_taxon(acanthognathus).should == ['Ponerinae', nil, 'Acanothognathus', nil, 'Bolton, 2011', nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
    end

    it "should export a genus without a subfamily as being in 'incertae_sedis'" do
      acanthognathus = create_genus 'Acanothognathus', tribe: nil, subfamily: nil
      acanthognathus.stub(:authorship_string).and_return 'Fisher, 2013'
      @exporter.export_taxon(acanthognathus).should == ['incertae_sedis', nil, 'Acanothognathus', nil, 'Fisher, 2013', nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
    end

    # Waiting to hear from Brian
    #describe "Invalid/unidentifiable/unresolved_homonyms" do
      #it "should not export invalid taxa" do
        #tribe = create_tribe subfamily: @ponerinae
        #valid_genus = create_genus subfamily: @ponerinae, tribe: tribe
        #invalid_genus = create_genus subfamily: @ponerinae, tribe: tribe, status: 'synonym'
        #unidentifiable_genus = create_genus subfamily: @ponerinae, tribe: tribe, status: 'unidentifiable'
        #@exporter.export_taxon(valid_genus).should =~ [@ponerinae.name.to_s, tribe.name.to_s, valid_genus.name.to_s, nil, nil, nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
        #@exporter.export_taxon(unidentifiable_genus).should == [@ponerinae.name.to_s, tribe.name.to_s, unidentifiable_genus.name.to_s, nil, nil, nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
        #@exporter.export_taxon(invalid_genus).should == nil
      #end

      #it "should export unidentifiable and unresolved junior homonyms" do
        #valid_genus = create_genus
        #unidentifiable_genus = create_genus status: 'unidentifiable'
        #unresolved_homonym_genus = create_genus unresolved_homonym: true
        #@exporter.export_taxon(valid_genus).should_not be_nil
        #@exporter.export_taxon(unidentifiable_genus).should_not be_nil
        #@exporter.export_taxon(unresolved_homonym_genus).should_not be_nil
      #end

      #it "should not export unidentifiable and unresolved junior homonyms if there is a taxon with the same name that is not unidentifiable or an unresolved junior homonym" do
        #valid = create_genus 'Atta'
        #unidentifiable = create_genus 'Atta', status: 'unidentifiable'
        #unresolved_homonym = create_genus 'Atta', unresolved_homonym: true
        ##@exporter.export_taxon(valid).should_not be_nil
        #@exporter.export_taxon(unidentifiable).should be_nil
        ##@exporter.export_taxon(unresolved_homonym).should be_nil
      #end

      #it "choose the unidentifiable one if one is unidentifiable and the other is an unresolved_homonym" do
        #unidentifiable = create_genus 'Atta', status: 'unidentifiable'
        #unresolved_homonym = create_genus 'Atta', unresolved_homonym: true
        #@exporter.export_taxon(unidentifiable).should_not be_nil
        #@exporter.export_taxon(unresolved_homonym).should be_nil
      #end
    #end

    describe "Exporting species" do
      it "should export one correctly" do
        atta = create_genus 'Atta', tribe: @attini
        species = create_species 'Atta robustus', genus: atta
        species.stub(:authorship_string).and_return 'Bolton, 2011'
        @exporter.export_taxon(species).should == ['Ponerinae', 'Attini', 'Atta', 'robustus', 'Bolton, 2011', nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
      end
      it "should export a species without a tribe" do
        atta = create_genus 'Atta', subfamily: @ponerinae, tribe: nil
        species = create_species 'Atta robustus', genus: atta
        species.stub(:authorship_string).and_return 'Bolton, 2011'
        @exporter.export_taxon(species).should == ['Ponerinae', nil, 'Atta', 'robustus', 'Bolton, 2011', nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
      end
      it "should export a species without a subfamily as being in the 'incertae sedis' subfamily" do
        atta = create_genus 'Atta', subfamily: nil, tribe: nil
        species = create_species 'Atta robustus', genus: atta
        species.stub(:authorship_string).and_return 'Bolton, 2011'
        @exporter.export_taxon(species).should == ['incertae_sedis', nil, 'Atta', 'robustus', 'Bolton, 2011', nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
      end
    end

    describe "Exporting subspecies" do
      it "should export one correctly" do
        atta = create_genus 'Atta', subfamily: @ponerinae, tribe: @attini
        species = create_species 'Atta robustus', subfamily: @ponerinae, genus: atta
        subspecies = create_subspecies 'Atta robustus emeryii', subfamily: @ponerinae, genus: atta, species: species
        subspecies.stub(:authorship_string).and_return 'Bolton, 2011'
        @exporter.export_taxon(subspecies).should == ['Ponerinae', 'Attini', 'Atta', 'robustus emeryii', 'Bolton, 2011', nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
      end
      it "should export a subspecies without a tribe" do
        atta = create_genus 'Atta', subfamily: @ponerinae, tribe: nil
        species = create_species 'Atta robustus', subfamily: @ponerinae, genus: atta
        subspecies = create_subspecies 'Atta robustus emeryii', genus: atta, species: species
        subspecies.stub(:authorship_string).and_return 'Bolton, 2011'
        @exporter.export_taxon(subspecies).should == ['Ponerinae', nil, 'Atta', 'robustus emeryii', 'Bolton, 2011', nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
      end
      it "should export a subspecies without a subfamily as being in the 'incertae sedis' subfamily" do
        atta = create_genus 'Atta', subfamily: nil, tribe: nil
        species = create_species 'Atta robustus', subfamily: nil, genus: atta
        subspecies = create_subspecies 'Atta robustus emeryii', subfamily: nil, genus: atta, species: species
        subspecies.stub(:authorship_string).and_return 'Bolton, 2011'
        @exporter.export_taxon(subspecies).should == ['incertae_sedis', nil, 'Atta', 'robustus emeryii', 'Bolton, 2011', nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
      end

    end
  end

  describe "Author/date column" do
    it "should export the author and date of the taxon" do
      bolton = FactoryGirl.create :author
      author_name = FactoryGirl.create :author_name, name: 'Bolton, B.', author: bolton
      journal = FactoryGirl.create :journal, name: 'Psyche'
      reference = ArticleReference.new author_names: [author_name], title: 'Ants I have known', citation_year: '2010a', year: 2010,
        journal: journal, series_volume_issue: '1', pagination: '2'
      authorship = Citation.create! reference: reference, pages: '12'
      name = FactoryGirl.create :genus_name, name: 'Atta'
      protonym = Protonym.create! name: name, authorship: authorship
      genus = create_genus name: name, protonym: protonym
      species = create_species 'Atta major', genus: genus
      genus.update_attribute :type_name, species.name

      @exporter.export_taxon(genus)[4].should == 'Bolton, 2010'
    end
  end

end
