# coding: UTF-8
require 'spec_helper'

describe Exporters::Antweb::Exporter do
  before do
    @exporter = Exporters::Antweb::Exporter.new
    stub = double format: 'history'
    Exporters::Antweb::Formatter.stub(:new).and_return stub
  end

  describe "The header" do
    it "should be the same as the code" do
      @exporter.header.should == "antcat id\t" +
                                 "subfamily\t" +
                                 "tribe\t" +
                                 "genus\t" +
                                 "subgenus\t" +
                                 "species\t" +
                                 "subspecies\t" +
                                 "author date\t" +
                                 "author date html\t" +
                                 "authors\t" +
                                 "year\t" +
                                 "status\t" +
                                 "available\t" +
                                 "current valid name\t" +
                                 "original combination\t" +
                                 "was original combination\t" +
                                 "fossil\t" +
                                 "taxonomic history html\t" +
                                 "reference id\t" +
                                 "bioregion\t" +
                                 "country\t" +
                                 "current valid rank" +
                                 "current valid parent" +
                                 ""
    end
  end

  describe "exporting one taxon" do
    before do
      @ponerinae = create_subfamily 'Ponerinae'
      @attini = create_tribe 'Attini', subfamily: @ponerinae
      Formatters::ReferenceFormatter.stub(:format_authorship_html).and_return '<span title="Bolton. Ants>Bolton, 1970</span>'
    end

    it "should export a subfamily" do
      create_genus subfamily: @ponerinae, tribe: nil
      @ponerinae.stub(:authorship_string).and_return('Bolton, 2011')
      @ponerinae.stub(:author_last_names_string).and_return('Bolton')
      @ponerinae.stub(:year).and_return 2001
      @exporter.export_taxon(@ponerinae)[0..17].should == [@ponerinae.id, 'Ponerinae', nil, nil, nil, nil, nil, 'Bolton, 2011', '<span title="Bolton. Ants>Bolton, 1970</span>', 'Bolton', '2001', 'valid', 'TRUE', 'Ponerinae', 'FALSE', nil, 'FALSE', 'history']
    end

    it "should export fossil taxa" do
      create_genus subfamily: @ponerinae, tribe: nil
      fossil = create_genus 'Atta', subfamily: @ponerinae, tribe: nil, fossil: true
      @ponerinae.stub(:authorship_string).and_return 'Bolton, 2011'
      @ponerinae.stub(:author_last_names_string).and_return('Bolton')
      @ponerinae.stub(:year).and_return 2001
      fossil.stub(:authorship_string).and_return 'Fisher, 2013'
      fossil.stub(:author_last_names_string).and_return('Fisher')
      fossil.stub(:year).and_return 2001
      @exporter.export_taxon(@ponerinae)[0..17].should == [@ponerinae.id, 'Ponerinae', nil, nil, nil, nil, nil, 'Bolton, 2011', '<span title="Bolton. Ants>Bolton, 1970</span>', 'Bolton', '2001', 'valid', 'TRUE', 'Ponerinae', 'FALSE', nil, 'FALSE', 'history']
      @exporter.export_taxon(fossil)[0..17].should == [fossil.id, 'Ponerinae', nil, 'Atta', nil, nil, nil, 'Fisher, 2013', '<span title="Bolton. Ants>Bolton, 1970</span>', 'Fisher', '2001', 'valid', 'TRUE', 'Atta', 'FALSE', nil, 'TRUE', 'history']
    end

    it "should export a genus" do
      dacetini = create_tribe 'Dacetini', subfamily: @ponerinae
      acanthognathus = create_genus 'Acanothognathus', subfamily: @ponerinae, tribe: dacetini
      acanthognathus.stub(:authorship_string).and_return 'Bolton, 2011'
      acanthognathus.stub(:author_last_names_string).and_return('Bolton')
      acanthognathus.stub(:year).and_return 2001
      @exporter.export_taxon(acanthognathus)[0..17].should == [acanthognathus.id, 'Ponerinae', 'Dacetini', 'Acanothognathus', nil, nil, nil, 'Bolton, 2011', '<span title="Bolton. Ants>Bolton, 1970</span>', 'Bolton', '2001', 'valid', 'TRUE', 'Acanothognathus', 'FALSE', nil, 'FALSE', 'history']
    end

    it "should export a genus without a tribe" do
      acanthognathus = create_genus 'Acanothognathus', subfamily: @ponerinae, tribe: nil
      acanthognathus.stub(:authorship_string).and_return 'Bolton, 2011'
      acanthognathus.stub(:author_last_names_string).and_return('Bolton')
      acanthognathus.stub(:year).and_return 2001
      @exporter.export_taxon(acanthognathus)[0..17].should == [acanthognathus.id, 'Ponerinae', nil, 'Acanothognathus', nil, nil, nil, 'Bolton, 2011', '<span title="Bolton. Ants>Bolton, 1970</span>', 'Bolton', '2001', 'valid', 'TRUE', 'Acanothognathus', 'FALSE', nil, 'FALSE', 'history']
    end

    it "should export a genus without a subfamily as being in 'incertae_sedis'" do
      acanthognathus = create_genus 'Acanothognathus', tribe: nil, subfamily: nil
      acanthognathus.stub(:authorship_string).and_return 'Fisher, 2013'
      acanthognathus.stub(:author_last_names_string).and_return('Fisher')
      acanthognathus.stub(:year).and_return 2001
      @exporter.export_taxon(acanthognathus)[0..17].should == [acanthognathus.id, 'incertae_sedis', nil, 'Acanothognathus', nil, nil, nil, 'Fisher, 2013',  '<span title="Bolton. Ants>Bolton, 1970</span>', 'Fisher', '2001', 'valid', 'TRUE', 'Acanothognathus', 'FALSE', nil, 'FALSE', 'history']
    end

    describe "Exporting species" do
      it "should export one correctly" do
        atta = create_genus 'Atta', tribe: @attini
        species = create_species 'Atta robustus', genus: atta
        species.stub(:authorship_string).and_return 'Bolton, 2011'
        species.stub(:author_last_names_string).and_return('Bolton')
        species.stub(:year).and_return 2001
        @exporter.export_taxon(species)[0..17].should == [species.id, 'Ponerinae', 'Attini', 'Atta', nil, 'robustus', nil, 'Bolton, 2011', '<span title="Bolton. Ants>Bolton, 1970</span>', 'Bolton', '2001', 'valid', 'TRUE', 'Atta robustus', 'FALSE', nil, 'FALSE', 'history']
      end
      it "should export a species without a tribe" do
        atta = create_genus 'Atta', subfamily: @ponerinae, tribe: nil
        species = create_species 'Atta robustus', genus: atta
        species.stub(:authorship_string).and_return 'Bolton, 2011'
        species.stub(:author_last_names_string).and_return('Bolton')
        species.stub(:year).and_return 2001
        @exporter.export_taxon(species)[0..17].should == [species.id, 'Ponerinae', nil, 'Atta', nil, 'robustus', nil, 'Bolton, 2011', '<span title="Bolton. Ants>Bolton, 1970</span>', 'Bolton', '2001', 'valid', 'TRUE', 'Atta robustus', 'FALSE', nil, 'FALSE', 'history']
      end
      it "should export a species without a subfamily as being in the 'incertae sedis' subfamily" do
        atta = create_genus 'Atta', subfamily: nil, tribe: nil
        species = create_species 'Atta robustus', genus: atta
        species.stub(:authorship_string).and_return 'Bolton, 2011'
        species.stub(:author_last_names_string).and_return('Bolton')
        species.stub(:year).and_return 2001
        @exporter.export_taxon(species)[0..17].should == [species.id, 'incertae_sedis', nil, 'Atta', nil, 'robustus', nil, 'Bolton, 2011', '<span title="Bolton. Ants>Bolton, 1970</span>', 'Bolton', '2001', 'valid', 'TRUE', 'Atta robustus', 'FALSE', nil, 'FALSE', 'history']
      end
    end

    describe "Exporting subspecies" do
      it "should export one correctly" do
        atta = create_genus 'Atta', subfamily: @ponerinae, tribe: @attini
        species = create_species 'Atta robustus', subfamily: @ponerinae, genus: atta
        subspecies = create_subspecies 'Atta robustus emeryii', subfamily: @ponerinae, genus: atta, species: species
        subspecies.stub(:authorship_string).and_return 'Bolton, 2011'
        subspecies.stub(:author_last_names_string).and_return('Bolton')
        subspecies.stub(:year).and_return 2001
        @exporter.export_taxon(subspecies)[0..17].should == [subspecies.id, 'Ponerinae', 'Attini', 'Atta', nil, 'robustus', 'emeryii', 'Bolton, 2011', '<span title="Bolton. Ants>Bolton, 1970</span>', 'Bolton', '2001', 'valid', 'TRUE', 'Atta robustus emeryii', 'FALSE', nil, 'FALSE', 'history']
      end
      it "should export a subspecies without a tribe" do
        atta = create_genus 'Atta', subfamily: @ponerinae, tribe: nil
        species = create_species 'Atta robustus', subfamily: @ponerinae, genus: atta
        subspecies = create_subspecies 'Atta robustus emeryii', genus: atta, species: species
        subspecies.stub(:authorship_string).and_return 'Bolton, 2011'
        subspecies.stub(:author_last_names_string).and_return('Bolton')
        subspecies.stub(:year).and_return 2001
        @exporter.export_taxon(subspecies)[0..17].should == [subspecies.id, 'Ponerinae', nil, 'Atta', nil, 'robustus', 'emeryii', 'Bolton, 2011', '<span title="Bolton. Ants>Bolton, 1970</span>', 'Bolton', '2001', 'valid', 'TRUE', 'Atta robustus emeryii', 'FALSE', nil, 'FALSE', 'history']
      end
      it "should export a subspecies without a subfamily as being in the 'incertae sedis' subfamily" do
        atta = create_genus 'Atta', subfamily: nil, tribe: nil
        species = create_species 'Atta robustus', subfamily: nil, genus: atta
        subspecies = create_subspecies 'Atta robustus emeryii', subfamily: nil, genus: atta, species: species
        subspecies.stub(:authorship_string).and_return 'Bolton, 2011'
        subspecies.stub(:author_last_names_string).and_return('Bolton')
        subspecies.stub(:year).and_return 2001
        @exporter.export_taxon(subspecies)[0..17].should == [subspecies.id, 'incertae_sedis', nil, 'Atta', nil, 'robustus', 'emeryii', 'Bolton, 2011', '<span title="Bolton. Ants>Bolton, 1970</span>', 'Bolton', '2001', 'valid', 'TRUE', 'Atta robustus emeryii', 'FALSE', nil, 'FALSE', 'history']
      end

    end
  end

  describe "Current valid name" do
    it "should export the current valid name of the taxon" do
      taxon = create_genus
      old = create_genus
      taxon.update_attributes! current_valid_taxon_id: old.id
      @exporter.export_taxon(taxon)[13].should == old.name.name
    end
  end

  describe "Sending all taxa - not just valid" do
    it "should export a junior synonym" do
      taxon = create_genus status: 'original combination'
      results = @exporter.export_taxon(taxon)
      results.should_not be_nil
      results[11].should == 'original combination'
    end
    it "should export a Tribe" do
      taxon = create_tribe
      results = @exporter.export_taxon(taxon)
      results.should_not be_nil
    end
    it "should export a Subgenus" do
      taxon = create_subgenus 'Atta (Boyo)'
      results = @exporter.export_taxon(taxon)
      results[4].should == 'Boyo'
    end
  end

  describe "Sending 'was original combination' so that AntWeb knows when to use parentheses around authorship" do
    it "should send TRUE or FALSE" do
      taxon = create_genus status: 'original combination'
      @exporter.export_taxon(taxon)[14].should == 'TRUE'
    end
    it "should send TRUE or FALSE" do
      taxon = create_genus
      @exporter.export_taxon(taxon)[14].should == 'FALSE'
    end
  end

  describe "Sending 'author_date_html' that includes the full reference in the rollover" do
    it "should do it" do
      journal = FactoryGirl.create :journal, name: "Neue Denkschriften"
      author_name = FactoryGirl.create :author_name, name: "Forel, A."
      reference = FactoryGirl.create(:article_reference, author_names: [author_name],
                          citation_year: "1874",
                          title: "Les fourmis de la Suisse",
                          journal: journal, series_volume_issue: "26", pagination: "1-452")
      taxon = create_genus
      taxon.protonym.authorship.reference = reference
      taxon.protonym.authorship.save!
      string = @exporter.export_taxon(taxon)[8]
      string.should == '<span title="Forel, A. 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452.">Forel, 1874</span>'
    end
  end

  describe "Original combination" do
    it "is the protonym, otherwise" do
      original_combination = create_species 'Atta major'
      recombination = create_species 'Eciton major'
      original_combination.status = 'original combination'
      original_combination.current_valid_taxon = recombination
      recombination.protonym.name = original_combination.name
      original_combination.save!
      recombination.save!
      string = @exporter.export_taxon(recombination)[15]
      string.should == original_combination.name.name
    end
  end

  describe "Reference ID" do
    it "should send the protonym's reference ID" do
      taxon = create_genus
      reference_id = @exporter.export_taxon(taxon)[18]
      reference_id.should == taxon.protonym.authorship.reference.id
    end
    it "should send nil if the protonym's reference is a MissingReference" do
      taxon = create_genus
      taxon.protonym.authorship.reference = FactoryGirl.create :missing_reference
      taxon.save!
      reference_id = @exporter.export_taxon(taxon)[18]
      reference_id.should be_nil
    end
  end

  describe "Sending other fields to AntWeb" do
    it "should send the biogeographic region" do
      taxon = create_genus biogeographic_region: 'Malaya'
      @exporter.export_taxon(taxon)[19].should == 'Malaya'
    end
    it "should send the locality" do
      taxon = create_genus protonym: FactoryGirl.create(:protonym, locality: 'Canada')
      @exporter.export_taxon(taxon)[20].should == 'Canada'
    end
  end

  describe "Current valid rank" do
    it "should send the right value for each class" do
      @exporter.export_taxon(create_subfamily)[21].should == 'Subfamily'
      @exporter.export_taxon(create_genus)[21].should == 'Genus'
      @exporter.export_taxon(create_subgenus)[21].should == 'Subgenus'
      @exporter.export_taxon(create_species)[21].should == 'Species'
      @exporter.export_taxon(create_subspecies)[21].should == 'Subspecies'
    end
  end

  describe "Current valid parent" do
    before do
      @subfamily = create_subfamily 'Dolichoderinae'
      @tribe = create_tribe 'Attini', subfamily: @subfamily
      @genus = create_genus 'Atta', tribe: @tribe, subfamily: @subfamily
      @subgenus = create_subgenus genus: @genus, tribe: @tribe, subfamily: @subfamily
      @species = create_species 'Atta betta', genus: @genus, subfamily: @subfamily
    end
    it "should not punt on a subfamily's family" do
      taxon = create_subfamily
      @exporter.export_taxon(taxon)[22].should == 'Formicidae'
    end
    it "should handle a taxon's subfamily" do
      taxon = create_tribe subfamily: @subfamily
      @exporter.export_taxon(taxon)[22].should == 'Dolichoderinae'
    end

    it "should skip over tribe and return the subfamily" do
      taxon = create_genus tribe: @tribe
      @exporter.export_taxon(taxon)[22].should == 'Dolichoderinae'
    end

    it "should skip over subgenus and return the genus" do
      taxon = create_species genus: @genus, subgenus: @subgenus
      @exporter.export_taxon(taxon)[22].should == 'Atta'
    end

    it "should handle a taxon's species" do
      taxon = create_subspecies 'Atta betta cappa', species: @species, genus: @genus, subfamily: @subfamily
      @exporter.export_taxon(taxon)[22].should == 'Atta betta'
    end
    it "should handle a synonym" do
      senior = create_genus 'Eciton', subfamily: @subfamily
      junior = create_genus 'Atta', subfamily: @subfamily, current_valid_taxon: senior
      taxon = create_species genus: junior
      Synonym.create! senior_synonym: senior, junior_synonym: junior
      @exporter.export_taxon(taxon)[22].should == 'Eciton'
    end
  end
end
