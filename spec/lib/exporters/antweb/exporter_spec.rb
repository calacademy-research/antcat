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
      @exporter.export_taxon(@ponerinae).should == [@ponerinae.id, 'Ponerinae', nil, nil, nil, 'Bolton, 2011', nil, 'valid', 'TRUE', 'Ponerinae', nil, 'FALSE', 'history']
    end

    it "should export fossil taxa" do
      create_genus subfamily: @ponerinae, tribe: nil
      fossil = create_genus 'Atta', subfamily: @ponerinae, tribe: nil, fossil: true
      @ponerinae.stub(:authorship_string).and_return 'Bolton, 2011'
      fossil.stub(:authorship_string).and_return 'Fisher, 2013'
      @exporter.export_taxon(@ponerinae).should == [@ponerinae.id, 'Ponerinae', nil, nil, nil, 'Bolton, 2011', nil, 'valid', 'TRUE', 'Ponerinae', nil, 'FALSE', 'history']
      @exporter.export_taxon(fossil).should == [fossil.id, 'Ponerinae', nil, 'Atta', nil, 'Fisher, 2013', nil, 'valid', 'TRUE', 'Atta', nil, 'TRUE', 'history']
    end

    it "should export a genus" do
      dacetini = create_tribe 'Dacetini', subfamily: @ponerinae
      acanthognathus = create_genus 'Acanothognathus', subfamily: @ponerinae, tribe: dacetini
      acanthognathus.stub(:authorship_string).and_return 'Bolton, 2011'
      @exporter.export_taxon(acanthognathus).should == [acanthognathus.id, 'Ponerinae', 'Dacetini', 'Acanothognathus', nil, 'Bolton, 2011', nil, 'valid', 'TRUE', 'Acanothognathus', nil, 'FALSE', 'history']
    end

    it "should export a genus without a tribe" do
      acanthognathus = create_genus 'Acanothognathus', subfamily: @ponerinae, tribe: nil
      acanthognathus.stub(:authorship_string).and_return 'Bolton, 2011'
      @exporter.export_taxon(acanthognathus).should == [acanthognathus.id, 'Ponerinae', nil, 'Acanothognathus', nil, 'Bolton, 2011', nil, 'valid', 'TRUE', 'Acanothognathus', nil, 'FALSE', 'history']
    end

    it "should export a genus without a subfamily as being in 'incertae_sedis'" do
      acanthognathus = create_genus 'Acanothognathus', tribe: nil, subfamily: nil
      acanthognathus.stub(:authorship_string).and_return 'Fisher, 2013'
      @exporter.export_taxon(acanthognathus).should == [acanthognathus.id, 'incertae_sedis', nil, 'Acanothognathus', nil, 'Fisher, 2013', nil, 'valid', 'TRUE', 'Acanothognathus', nil, 'FALSE', 'history']
    end

    describe "Exporting species" do
      it "should export one correctly" do
        atta = create_genus 'Atta', tribe: @attini
        species = create_species 'Atta robustus', genus: atta
        species.stub(:authorship_string).and_return 'Bolton, 2011'
        @exporter.export_taxon(species).should == [species.id, 'Ponerinae', 'Attini', 'Atta', 'robustus', 'Bolton, 2011', nil, 'valid', 'TRUE', 'Atta robustus', nil, 'FALSE', 'history']
      end
      it "should export a species without a tribe" do
        atta = create_genus 'Atta', subfamily: @ponerinae, tribe: nil
        species = create_species 'Atta robustus', genus: atta
        species.stub(:authorship_string).and_return 'Bolton, 2011'
        @exporter.export_taxon(species).should == [species.id, 'Ponerinae', nil, 'Atta', 'robustus', 'Bolton, 2011', nil, 'valid', 'TRUE', 'Atta robustus', nil, 'FALSE', 'history']
      end
      it "should export a species without a subfamily as being in the 'incertae sedis' subfamily" do
        atta = create_genus 'Atta', subfamily: nil, tribe: nil
        species = create_species 'Atta robustus', genus: atta
        species.stub(:authorship_string).and_return 'Bolton, 2011'
        @exporter.export_taxon(species).should == [species.id, 'incertae_sedis', nil, 'Atta', 'robustus', 'Bolton, 2011', nil, 'valid', 'TRUE', 'Atta robustus', nil, 'FALSE', 'history']
      end
    end

    describe "Exporting subspecies" do
      it "should export one correctly" do
        atta = create_genus 'Atta', subfamily: @ponerinae, tribe: @attini
        species = create_species 'Atta robustus', subfamily: @ponerinae, genus: atta
        subspecies = create_subspecies 'Atta robustus emeryii', subfamily: @ponerinae, genus: atta, species: species
        subspecies.stub(:authorship_string).and_return 'Bolton, 2011'
        @exporter.export_taxon(subspecies).should == [subspecies.id, 'Ponerinae', 'Attini', 'Atta', 'robustus emeryii', 'Bolton, 2011', nil, 'valid', 'TRUE', 'Atta robustus emeryii', nil, 'FALSE', 'history']
      end
      it "should export a subspecies without a tribe" do
        atta = create_genus 'Atta', subfamily: @ponerinae, tribe: nil
        species = create_species 'Atta robustus', subfamily: @ponerinae, genus: atta
        subspecies = create_subspecies 'Atta robustus emeryii', genus: atta, species: species
        subspecies.stub(:authorship_string).and_return 'Bolton, 2011'
        @exporter.export_taxon(subspecies).should == [subspecies.id, 'Ponerinae', nil, 'Atta', 'robustus emeryii', 'Bolton, 2011', nil, 'valid', 'TRUE', 'Atta robustus emeryii', nil, 'FALSE', 'history']
      end
      it "should export a subspecies without a subfamily as being in the 'incertae sedis' subfamily" do
        atta = create_genus 'Atta', subfamily: nil, tribe: nil
        species = create_species 'Atta robustus', subfamily: nil, genus: atta
        subspecies = create_subspecies 'Atta robustus emeryii', subfamily: nil, genus: atta, species: species
        subspecies.stub(:authorship_string).and_return 'Bolton, 2011'
        @exporter.export_taxon(subspecies).should == [subspecies.id, 'incertae_sedis', nil, 'Atta', 'robustus emeryii', 'Bolton, 2011', nil, 'valid', 'TRUE', 'Atta robustus emeryii', nil, 'FALSE', 'history']
      end

    end
  end

  describe "Author/date column" do
    it "should export the author and date of the taxon" do
    end
  end

  describe "Current valid name" do
    it "should export the current valid name of the taxon" do
      taxon = create_genus
      old = create_genus
      taxon.update_attributes! current_valid_taxon_id: old.id
      @exporter.export_taxon(taxon)[9].should == old.name.name
    end
  end

  describe "Sending all taxa - not just valid" do
    it "should export a junior synonym" do
      taxon = create_genus status: 'original combination'
      results = @exporter.export_taxon(taxon)
      results.should_not be_nil
      results[7].should == 'original combination'
    end
    it "should export a Tribe" do
      taxon = create_tribe
      results = @exporter.export_taxon(taxon)
      results.should_not be_nil
    end
    it "should export a Subgenus" do
      taxon = create_subgenus
      results = @exporter.export_taxon(taxon)
      results.should_not be_nil
    end
  end

end
