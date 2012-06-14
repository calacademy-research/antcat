# coding: UTF-8
require 'spec_helper'

describe Antweb::Exporter do
  before do
    @exporter = Antweb::Exporter.new
  end

  describe "exporting one taxon" do
    it "should export a subfamily" do
      ponerinae = Factory :subfamily, name: FactoryGirl.create(:subfamily_name, name: 'Ponerinae'), :status => 'valid', :taxonomic_history => '<p>Ponerinae</p>'
      FactoryGirl.create :genus, :subfamily => ponerinae, :tribe => nil
      @exporter.export_taxon(ponerinae).should == ['Ponerinae', nil, nil, nil, nil, nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', '<p class="taxon_statistics">1 genus</p><p>Ponerinae</p>']
    end

    it "should export fossil taxa" do
      ponerinae = Factory :subfamily, name: FactoryGirl.create(:subfamily_name, name: 'Ponerinae'), :status => 'valid', :taxonomic_history => '<p>Ponerinae</p>'
      FactoryGirl.create :genus, :subfamily => ponerinae, :tribe => nil
      fossil = FactoryGirl.create :genus, name: FactoryGirl.create(:genus_name, name: 'Atta'), :taxonomic_history => 'Atta', :subfamily => ponerinae, :tribe => nil, :fossil => true
      @exporter.export_taxon(ponerinae).should == ['Ponerinae', nil, nil, nil, nil, nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', '<p class="taxon_statistics">Extant: 1 genus</p><p class="taxon_statistics">Fossil: 1 genus</p><p>Ponerinae</p>']
      @exporter.export_taxon(fossil).should == ['Ponerinae', nil, 'Atta', nil, nil, nil, 'TRUE', 'TRUE', nil, nil, 'TRUE', 'Atta']
    end

    it "should export a genus" do
      myrmicinae = Factory :subfamily, name: FactoryGirl.create(:subfamily_name, name: 'Myrmicinae'), :status => 'valid'
      dacetini = Factory :tribe, name: FactoryGirl.create(:tribe_name, name: 'Dacetini'), :subfamily => myrmicinae, :status => 'valid'
      acanthognathus = Factory :genus, name: FactoryGirl.create(:genus_name, name: 'Acanothognathus'), :subfamily => myrmicinae, :tribe => dacetini, :status => 'valid', :taxonomic_history => '<i>Acanthognathous</i>'
      Exporters::Antweb::Formatter.should_receive(:format_taxonomic_history_with_statistics_for_antweb).with(acanthognathus, :include_invalid => false).and_return 'history'
      @exporter.export_taxon(acanthognathus).should == ['Myrmicinae', 'Dacetini', 'Acanothognathus', nil, nil, nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
    end

    it "should export a genus without a tribe" do
      myrmicinae = Factory :subfamily, name: FactoryGirl.create(:subfamily_name, name: 'Myrmicinae'), :status => 'valid'
      acanthognathus = Factory :genus, name: FactoryGirl.create(:genus_name, name: 'Acanothognathus'), :subfamily => myrmicinae, :status => 'valid', :taxonomic_history => '<i>Acanthognathous</i>', tribe: nil
      Exporters::Antweb::Formatter.should_receive(:format_taxonomic_history_with_statistics_for_antweb).with(acanthognathus, :include_invalid => false).and_return 'history'
      @exporter.export_taxon(acanthognathus).should == ['Myrmicinae', nil, 'Acanothognathus', nil, nil, nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
    end

    it "should export a genus without a subfamily as being in 'incertae_sedis'" do
      acanthognathus = Factory :genus, name: FactoryGirl.create(:genus_name, name: 'Acanothognathus'), :status => 'valid', :taxonomic_history => '<i>Acanthognathous</i>', tribe: nil, subfamily: nil
      Exporters::Antweb::Formatter.should_receive(:format_taxonomic_history_with_statistics_for_antweb).with(acanthognathus, :include_invalid => false).and_return 'history'
      @exporter.export_taxon(acanthognathus).should == ['incertae_sedis', nil, 'Acanothognathus', nil, nil, nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
    end

    it "should not export invalid taxa" do
      subfamily = FactoryGirl.create :subfamily
      tribe = FactoryGirl.create :tribe, :subfamily => subfamily
      valid_genus = FactoryGirl.create :genus, :subfamily => subfamily, :tribe => tribe, :status => 'valid'
      invalid_genus = FactoryGirl.create :genus, :subfamily => subfamily, :tribe => tribe, :status => 'syononym'
      unidentifiable_genus = FactoryGirl.create :genus, :subfamily => subfamily, :tribe => tribe, :status => 'unidentifiable'
      unidentifiable_genus.should be_unidentifiable
      Exporters::Antweb::Formatter.should_receive(:format_taxonomic_history_with_statistics_for_antweb).with(unidentifiable_genus, :include_invalid => false).and_return 'history'
      Exporters::Antweb::Formatter.should_receive(:format_taxonomic_history_with_statistics_for_antweb).with(valid_genus, :include_invalid => false).and_return 'history'
      Exporters::Antweb::Formatter.should_not_receive(:format_taxonomic_history_with_statistics_for_antweb).with(invalid_genus, :include_invalid => false)
      @exporter.export_taxon(valid_genus).should == [subfamily.name.to_s, tribe.name.to_s, valid_genus.name.to_s, nil, nil, nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
      @exporter.export_taxon(unidentifiable_genus).should == [subfamily.name.to_s, tribe.name.to_s, unidentifiable_genus.name.to_s, nil, nil, nil, 'FALSE', 'FALSE', nil, nil, 'FALSE', 'history']
      @exporter.export_taxon(invalid_genus).should == nil
    end

    it "should not export an invalid taxon" do
      acalama = FactoryGirl.create :genus,  :status => 'synonym'
      Exporters::Antweb::Formatter.should_not_receive(:format_taxonomic_history_with_statistics_for_antweb)
      @exporter.export_taxon(acalama).should == nil
    end

    describe "Exporting species" do

      it "should export one correctly" do
        myrmicinae = FactoryGirl.create :subfamily, name: FactoryGirl.create(:subfamily_name, name: 'Myrmicinae')
        attini = FactoryGirl.create :tribe, name: FactoryGirl.create(:tribe_name, name: 'Attini'), :subfamily => myrmicinae
        atta = FactoryGirl.create :genus, name: FactoryGirl.create(:genus_name, name: 'Atta'), :tribe => attini
        species = FactoryGirl.create :species, name: FactoryGirl.create(:species_name, name: 'Atta robustus', epithet: 'robustus'), :genus => atta, :taxonomic_history => 'history'
        Exporters::Antweb::Formatter.should_receive(:format_taxonomic_history_with_statistics_for_antweb).with(species, :include_invalid => false).and_return 'history'
        @exporter.export_taxon(species).should == ['Myrmicinae', 'Attini', 'Atta', 'robustus', nil, nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
      end

      it "should export a species without a tribe" do
        myrmicinae = FactoryGirl.create :subfamily, name: FactoryGirl.create(:subfamily_name, name: 'Myrmicinae')
        atta = FactoryGirl.create :genus, name: FactoryGirl.create(:genus_name, name: 'Atta'), :subfamily => myrmicinae, :tribe => nil
        species = FactoryGirl.create :species, name: FactoryGirl.create(:species_name, name: 'Atta robustus', epithet: 'robustus'), :genus => atta, :taxonomic_history => 'history'
        Exporters::Antweb::Formatter.should_receive(:format_taxonomic_history_with_statistics_for_antweb).with(species, :include_invalid => false).and_return 'history'
        @exporter.export_taxon(species).should == ['Myrmicinae', nil, 'Atta', 'robustus', nil, nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
      end

      it "should export a species without a subfamily as being in the 'incertae sedis' subfamily" do
        atta = FactoryGirl.create :genus, name: FactoryGirl.create(:genus_name, name: 'Atta'), :subfamily => nil, :tribe => nil
        species = FactoryGirl.create :species, name: FactoryGirl.create(:species_name, name: 'Atta robustus', epithet: 'robustus'), :genus => atta, :taxonomic_history => 'history'
        Exporters::Antweb::Formatter.should_receive(:format_taxonomic_history_with_statistics_for_antweb).with(species, :include_invalid => false).and_return 'history'
        @exporter.export_taxon(species).should == ['incertae_sedis', nil, 'Atta', 'robustus', nil, nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
      end

    end

    describe "Exporting subspecies" do

      it "should export one correctly" do
        myrmicinae = FactoryGirl.create :subfamily, name: FactoryGirl.create(:subfamily_name, name: 'Myrmicinae')
        attini = FactoryGirl.create :tribe, name: FactoryGirl.create(:genus_name, name: 'Attini'), :subfamily => myrmicinae
        atta = FactoryGirl.create :genus, name: FactoryGirl.create(:genus_name, name: 'Atta'), :tribe => attini
        species = FactoryGirl.create :species, name: FactoryGirl.create(:species_name, name: 'Atta robustus', epithet: 'robustus'), :genus => atta
        subspecies = FactoryGirl.create :subspecies, name: FactoryGirl.create(:subspecies_name, name: 'Atta robustus emeryii', epithet: 'robustus emeryii'), :species => species, :taxonomic_history => 'history'
        Exporters::Antweb::Formatter.should_receive(:format_taxonomic_history_with_statistics_for_antweb).with(subspecies, :include_invalid => false).and_return 'history'
        @exporter.export_taxon(subspecies).should == ['Myrmicinae', 'Attini', 'Atta', 'robustus emeryii', nil, nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
      end

      it "should export a subspecies without a tribe" do
        myrmicinae = FactoryGirl.create :subfamily, name: FactoryGirl.create(:subfamily_name, name: 'Myrmicinae')
        atta = FactoryGirl.create :genus, name: FactoryGirl.create(:genus_name, name: 'Atta'), :subfamily => myrmicinae, :tribe => nil
        species = FactoryGirl.create :species, name: FactoryGirl.create(:species_name, name: 'Atta robustus', epithet: 'robustus'), :genus => atta, :taxonomic_history => 'history'
        subspecies = FactoryGirl.create :subspecies, name: FactoryGirl.create(:subspecies_name, name: 'Atta robustus emeryii', epithet: 'robustus emeryii'), :species => species, :taxonomic_history => 'history'
        Exporters::Antweb::Formatter.should_receive(:format_taxonomic_history_with_statistics_for_antweb).with(subspecies, :include_invalid => false).and_return 'history'
        @exporter.export_taxon(subspecies).should == ['Myrmicinae', nil, 'Atta', 'robustus emeryii', nil, nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
      end

      it "should export a subspecies without a subfamily as being in the 'incertae sedis' subfamily" do
        atta = FactoryGirl.create :genus, name: FactoryGirl.create(:genus_name, name: 'Atta'), :subfamily => nil, :tribe => nil
        species = FactoryGirl.create :species, name: FactoryGirl.create(:species_name, name: 'Atta robustus', epithet: 'robustus'), :genus => atta, :taxonomic_history => 'history'
        subspecies = FactoryGirl.create :subspecies, name: FactoryGirl.create(:subspecies_name, name: 'Atta robustus emeryii', epithet: 'robustus emeryii'), :species => species, :taxonomic_history => 'history'
        Exporters::Antweb::Formatter.should_receive(:format_taxonomic_history_with_statistics_for_antweb).with(subspecies, :include_invalid => false).and_return 'history'
        @exporter.export_taxon(subspecies).should == ['incertae_sedis', nil, 'Atta', 'robustus emeryii', nil, nil, 'TRUE', 'TRUE', nil, nil, 'FALSE', 'history']
      end

    end
  end
end
