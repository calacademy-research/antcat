require 'spec_helper'

describe Subgenus do

  it "must have a genus" do
    colobopsis = Subgenus.new(:name => 'Colobopsis')
    colobopsis.should_not be_valid
    colobopsis.genus = Factory :genus, :name => 'Camponotus'
    colobopsis.save!
    colobopsis.reload.genus.name.should == 'Camponotus'
  end

  describe "Import" do

    it "should import all the fields correctly" do
      subgenus = Subgenus.import :name => 'Colobopsis',
        :genus => 'Camponotus',
        :fossil => true, :status => :valid,
        :taxonomic_history => '<p>history</p>'
      subgenus.reload
      subgenus.name.should == 'Colobopsis'
      subgenus.genus.name.should == 'Camponotus'
      subgenus.fossil?.should be_true
      subgenus.status.should == 'valid'
      subgenus.taxonomic_history.should == '<p>history</p>'
      subgenus.incertae_sedis_in.should be_nil
    end

    it "should not create the genus if the passed-in information isn't valid" do
      lambda {Subgenus.import :name => 'Acalama', :status => :valid, :genus => ''}.should raise_error
    end

  end
end
