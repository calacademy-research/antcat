require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BookReference do

  describe "importing a new reference" do

    it "should create the reference and set its data" do
      ward_reference = Factory(:ward_reference)
      reference = BookReference.import(
        {:title => 'awdf', :source_reference_id => ward_reference.id, :source_reference_type => 'WardReference'},
        {:pagination => '32 pp.', :publisher => {:name => 'Wiley', :place => 'Chicago'}})
      reference.pagination.should == '32 pp.'
      reference.publisher.name.should == 'Wiley'
      reference.publisher.place.should == 'Chicago'
      reference.source_reference.should == ward_reference
    end

  end

  describe "citation" do
    it "should format a citation" do
      publisher = Publisher.create! :name => "Wiley", :place => 'New York'
      reference = BookReference.new :title => 'asdf', :publisher => publisher, :pagination => '32 pp.'
      reference.citation.should == 'New York: Wiley. 32 pp.'
    end
  end

end
