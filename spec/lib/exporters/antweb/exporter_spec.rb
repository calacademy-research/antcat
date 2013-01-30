# coding: UTF-8
require 'spec_helper'

describe Exporters::Antweb::Exporter do
  before do
    @exporter = Exporters::Antweb::Exporter.new
    stub = mock format: 'history'
    Exporters::Antweb::Formatter.stub(:new).and_return stub
  end

  describe "exporting one taxon" do
    before do
      @ponerinae = create_subfamily 'Ponerinae'
      @attini = create_tribe 'Attini', subfamily: @ponerinae
    end

    it "should export a subfamily" do
      create_genus subfamily: @ponerinae, tribe: nil
      @exporter.export_taxon(@ponerinae).should == ['Ponerinae', nil, nil, nil, nil, nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
    end

    it "should export fossil taxa" do
      create_genus subfamily: @ponerinae, tribe: nil
      fossil = create_genus 'Atta', subfamily: @ponerinae, tribe: nil, fossil: true
      @exporter.export_taxon(@ponerinae).should == ['Ponerinae', nil, nil, nil, nil, nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
      @exporter.export_taxon(fossil).should == ['Ponerinae', nil, 'Atta', nil, nil, nil, 'TRUE', 'TRUE', nil, nil, 'TRUE', 'history']
    end

    it "should export a genus" do
      dacetini = create_tribe 'Dacetini', subfamily: @ponerinae
      acanthognathus = create_genus 'Acanothognathus', subfamily: @ponerinae, tribe: dacetini
      @exporter.export_taxon(acanthognathus).should == ['Ponerinae', 'Dacetini', 'Acanothognathus', nil, nil, nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
    end

    it "should export a genus without a tribe" do
      acanthognathus = create_genus 'Acanothognathus', subfamily: @ponerinae, tribe: nil
      @exporter.export_taxon(acanthognathus).should == ['Ponerinae', nil, 'Acanothognathus', nil, nil, nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
    end

    it "should export a genus without a subfamily as being in 'incertae_sedis'" do
      acanthognathus = create_genus 'Acanothognathus', tribe: nil, subfamily: nil
      @exporter.export_taxon(acanthognathus).should == ['incertae_sedis', nil, 'Acanothognathus', nil, nil, nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
    end

    it "should not export invalid taxa" do
      tribe = create_tribe subfamily: @ponerinae
      valid_genus = create_genus subfamily: @ponerinae, tribe: tribe
      invalid_genus = create_genus subfamily: @ponerinae, tribe: tribe, status: 'synonym'
      unidentifiable_genus = create_genus subfamily: @ponerinae, tribe: tribe, status: 'valid', unidentifiable: true
      @exporter.export_taxon(valid_genus).should =~ [@ponerinae.name.to_s, tribe.name.to_s, valid_genus.name.to_s, nil, nil, nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
      @exporter.export_taxon(unidentifiable_genus).should == [@ponerinae.name.to_s, tribe.name.to_s, unidentifiable_genus.name.to_s, nil, nil, nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
      @exporter.export_taxon(invalid_genus).should == nil
    end

    describe "Exporting species" do
      it "should export one correctly" do
        atta = create_genus 'Atta', tribe: @attini
        species = create_species 'Atta robustus', genus: atta
        @exporter.export_taxon(species).should == ['Ponerinae', 'Attini', 'Atta', 'robustus', nil, nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
      end
      it "should export a species without a tribe" do
        atta = create_genus 'Atta', subfamily: @ponerinae, tribe: nil
        species = create_species 'Atta robustus', genus: atta
        @exporter.export_taxon(species).should == ['Ponerinae', nil, 'Atta', 'robustus', nil, nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
      end
      it "should export a species without a subfamily as being in the 'incertae sedis' subfamily" do
        atta = create_genus 'Atta', subfamily: nil, tribe: nil
        species = create_species 'Atta robustus', genus: atta
        @exporter.export_taxon(species).should == ['incertae_sedis', nil, 'Atta', 'robustus', nil, nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
      end
    end

    describe "Exporting subspecies" do
      it "should export one correctly" do
        atta = create_genus 'Atta', subfamily: @ponerinae, tribe: @attini
        species = create_species 'Atta robustus', subfamily: @ponerinae, genus: atta
        subspecies = create_subspecies 'Atta robustus emeryii', subfamily: @ponerinae, genus: atta, species: species
        @exporter.export_taxon(subspecies).should == ['Ponerinae', 'Attini', 'Atta', 'robustus emeryii', nil, nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
      end
      it "should export a subspecies without a tribe" do
        atta = create_genus 'Atta', subfamily: @ponerinae, tribe: nil
        species = create_species 'Atta robustus', subfamily: @ponerinae, genus: atta
        subspecies = create_subspecies 'Atta robustus emeryii', genus: atta, species: species
        @exporter.export_taxon(subspecies).should == ['Ponerinae', nil, 'Atta', 'robustus emeryii', nil, nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
      end
      it "should export a subspecies without a subfamily as being in the 'incertae sedis' subfamily" do
        atta = create_genus 'Atta', subfamily: nil, tribe: nil
        species = create_species 'Atta robustus', subfamily: nil, genus: atta
        subspecies = create_subspecies 'Atta robustus emeryii', subfamily: nil, genus: atta, species: species
        @exporter.export_taxon(subspecies).should == ['incertae_sedis', nil, 'Atta', 'robustus emeryii', nil, nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
      end

    end
  end
end
