require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BookReference do
  describe "importing a new reference" do
    it "should create the reference and set its data" do
      ward_reference = Factory(:ward_reference)
      reference = BookReference.import(
        {:author_names => [Factory(:author_name)], :title => 'awdf',
          :source_reference_id => ward_reference.id, :source_reference_type => 'WardReference', :citation_year => '2010a'},
        {:pagination => '32 pp.', :publisher => {:name => 'Wiley', :place => 'Chicago'}})
      reference.pagination.should == '32 pp.'
      reference.publisher.name.should == 'Wiley'
      reference.publisher.place.name.should == 'Chicago'
      reference.source_reference.should == ward_reference
    end
  end

end
