require 'spec_helper'

describe AuthorityList::Exporter do
  before do
    @exporter = AuthorityList::Exporter.new
  end

  it "should write its output to the right file" do
    File.should_receive(:open).with 'data/output/antcat_authority_list.txt', 'w'
    @exporter.export 'data/output'
  end

  it "should include the correct header" do
    file = stub
    File.stub(:open).and_yield file
    file.should_receive(:puts).with "subfamily\ttribe\tgenus\tspecies\tsubspecies\tstatus\tsenior synonym\tfossil"
    @exporter.export 'data/output'
  end

  describe "Outputting taxa" do
    before do
      @subfamily = Factory :subfamily, :name => 'Myrmicinae'
      @tribe = Factory :tribe, :name => 'Attini', :subfamily => @subfamily
      @genus = Factory :genus, :name => 'Atta', :subfamily => @subfamily, :tribe => @tribe
      @species = Factory :species, :name => 'robusta', :subfamily => @subfamily, :genus => @genus
    end

    it "should export a species correctly" do
      @exporter.get_data(@species).should == ['Myrmicinae', 'Attini', 'Atta', 'robusta', '', 'valid', '', '']
    end

    it "should export a fossil species correctly" do
      @species.update_attribute :fossil, true
      @exporter.get_data(@species).should == ['Myrmicinae', 'Attini', 'Atta', 'robusta', '', 'valid', '', 'fossil']
    end

    it "should not export genera (or subfamilies or tribes)" do
      @exporter.should_receive(:write).twice
      @exporter.export 'data/output'
    end

    describe "Outputting subspecies" do
      before do
        @subspecies = Factory :subspecies, :name => 'rufa', :genus => @genus, :species => @species
      end

      it "should export a subspecies correctly" do
        @exporter.get_data(@subspecies).should == ['Myrmicinae', 'Attini', 'Atta', 'robusta', 'rufa', 'valid', '', '']
      end

      it "should export subspecies as well as species" do
        @exporter.should_receive(:write).exactly(3).times
        @exporter.export 'data/output'
      end

    end
  end

  describe "Outputting a number of taxa" do
    it "should sort its output by names in ranks" do
      file = stub
      File.stub(:open).and_yield file

      myrmicinae = Factory :subfamily, :name => 'Myrmicinae'

      attini = Factory :tribe, :name => 'Attini', :subfamily => myrmicinae
      cephalotini = Factory :tribe, :name => 'Cephalotini', :subfamily => myrmicinae

      atta = Factory :genus, :name => 'Atta', :tribe => attini, :subfamily => myrmicinae
      cephalotes = Factory :genus, :name => 'Cephalotes', :tribe => cephalotini, :subfamily => myrmicinae

      robusta = Factory :species, :name => 'robusta', :genus => atta
      adolphi = Factory :species, :name => 'adolphi', :genus => cephalotes

      rufa = Factory :subspecies, :name => 'rufa', :species => adolphi

      @exporter.should_receive(:write).with(file,
        "subfamily\ttribe\tgenus\tspecies\tsubspecies\tstatus\tsenior synonym\tfossil").ordered
      @exporter.should_receive(:write).with(file,
        "Myrmicinae\t" + "Attini\t" +      "Atta\t" +       "robusta\t" + "\t" + "valid\t\t").ordered
      @exporter.should_receive(:write).with(file,
        "Myrmicinae\t" + "Cephalotini\t" + "Cephalotes\t" + "adolphi\t" + "\t" + "valid\t\t").ordered
      @exporter.should_receive(:write).with(file,
        "Myrmicinae\t" + "Cephalotini\t" + "Cephalotes\t" + "adolphi\t" + "rufa\t" + "valid\t\t").ordered

      @exporter.export 'data/output'
    end
  end

  describe "Outputting the senior synonym of a species" do
    before do
      @atta = Factory :genus, :name => 'Atta'
      @senior_synonym = Factory :species, :name => 'formica', :genus => @atta
      @junior_synonym = Factory :species, :name => 'robusta', :genus => @atta, :status => 'synonym', :synonym_of => @senior_synonym
    end

    it "should not crash if it's a junior synonym but we don't know the senior" do
      @junior_synonym.update_attribute :synonym_of, nil
      @exporter.get_data(@junior_synonym).should == [@atta.subfamily.name, @atta.tribe.name, @atta.name, @junior_synonym.name, '', 'synonym', '', '']
    end

    it "should output the genus + species of the synonym" do
      @exporter.get_data(@junior_synonym).should == [@atta.subfamily.name, @atta.tribe.name, @atta.name, @junior_synonym.name, '', 'synonym', 'Atta formica', '']
    end

  end

end
