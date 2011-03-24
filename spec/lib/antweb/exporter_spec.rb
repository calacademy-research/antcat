require 'spec_helper'

describe Antweb::Exporter do
  before do
    @exporter = Antweb::Exporter.new
  end

  describe "exporting one taxon" do

    it "should export a subfamily" do
      ponerinae = Subfamily.create! :name => 'Ponerinae', :status => 'valid', :taxonomic_history => '<p>Ponerinae</p>'
      @exporter.export_taxon(ponerinae).should == ['Ponerinae', nil, nil, nil, nil, nil, 'TRUE', nil, nil, nil, '<p>Ponerinae</p>']
    end

    it "should export a genus" do
      myrmicinae = Subfamily.create! :name => 'Myrmicinae', :status => 'valid'
      dacetini = Tribe.create! :name => 'Dacetini', :subfamily => myrmicinae, :status => 'valid'
      acanthognathus = Genus.create! :name => 'Acanothognathus', :subfamily => myrmicinae, :tribe => dacetini, :status => 'valid', :taxonomic_history => '<i>Acanthognathous</i>'
      @exporter.export_taxon(acanthognathus).should == ['Myrmicinae', 'Dacetini', 'Acanothognathus', nil, nil, nil, 'TRUE', 'TRUE', nil, nil, '<i>Acanthognathous</i>']
    end

    it "should export a genus without a tribe" do
      myrmicinae = Subfamily.create! :name => 'Myrmicinae', :status => 'valid'
      acanthognathus = Genus.create! :name => 'Acanothognathus', :subfamily => myrmicinae, :status => 'valid', :taxonomic_history => '<i>Acanthognathous</i>'
      @exporter.export_taxon(acanthognathus).should == ['Myrmicinae', nil, 'Acanothognathus', nil, nil, nil, 'TRUE', 'TRUE', nil, nil, '<i>Acanthognathous</i>']
    end

    it "should export a genus without a subfamily as being in 'incertae_sedis'" do
      myrmicinae = Subfamily.create! :name => 'Myrmicinae', :status => 'valid'
      dacetini = Tribe.create! :name => 'Dacetini', :subfamily => myrmicinae, :status => 'valid'
      acanthognathus = Genus.create! :name => 'Acanothognathus', :subfamily => myrmicinae, :tribe => dacetini, :status => 'valid', :taxonomic_history => '<i>Acanthognathous</i>'
      @exporter.export_taxon(acanthognathus).should == ['Myrmicinae', 'Dacetini', 'Acanothognathus', nil, nil, nil, 'TRUE', 'TRUE', nil, nil, '<i>Acanthognathous</i>']
    end

    it "should not export invalid taxa" do
      subfamily = Factory :subfamily
      tribe = Factory :tribe, :subfamily => subfamily
      valid_genus = Factory :genus, :subfamily => subfamily, :tribe => tribe, :status => 'valid'
      invalid_genus = Factory :genus, :subfamily => subfamily, :tribe => tribe, :status => 'syononym'
      @exporter.export_taxon(valid_genus).should == [subfamily.name, tribe.name, valid_genus.name, nil, nil, nil, 'TRUE', 'TRUE', nil, nil, nil]
      @exporter.export_taxon(invalid_genus).should == nil
    end

    it "should not export an invalid taxon" do
      acalama = Factory :genus,  :status => 'synonym'
      @exporter.export_taxon(acalama).should == nil
    end

    describe "Exporting species" do

      it "should export one correctly" do
        myrmicinae = Factory :subfamily, :name => 'Myrmicinae'
        attini = Factory :tribe, :name => 'Attini', :subfamily => myrmicinae
        atta = Factory :genus, :name => 'Atta', :tribe => attini
        species = Factory :species, :name => 'robustus', :genus => atta, :taxonomic_history => 'Taxonomic history'
        @exporter.export_taxon(species).should == ['Myrmicinae', 'Attini', 'Atta', 'robustus', nil, nil, 'TRUE', 'TRUE', nil, nil, 'Taxonomic history']
      end

    end

    describe "Exporting subspecies" do

      it "should export one correctly" do
        myrmicinae = Factory :subfamily, :name => 'Myrmicinae'
        attini = Factory :tribe, :name => 'Attini', :subfamily => myrmicinae
        atta = Factory :genus, :name => 'Atta', :tribe => attini
        species = Factory :species, :name => 'robustus', :genus => atta
        subspecies = Factory :subspecies, :name => 'emeryii', :species => species, :taxonomic_history => 'Taxonomic history'
        @exporter.export_taxon(subspecies).should == ['Myrmicinae', 'Attini', 'Atta', 'robustus emeryii', nil, nil, 'TRUE', 'TRUE', nil, nil, 'Taxonomic history']
      end

    end

  end

end
