require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NestedReference do
  describe "importing a new reference" do
    it "should create the reference and set its data" do
      ward_reference = Factory :ward_reference
      reference = NestedReference.import(
        { :authors => [Factory :author],
          :citation_year => '2010a',
          :title => 'awdf',
          :source_reference_id => ward_reference.id,
          :source_reference_type => 'WardReference',
        },
        { :authors => ['Nested author'],
          :title => 'Nested title',
          :pages_in => 'In pp. 32-33:',
          :book => {
            :publisher => {:name => 'Wiley', :place => 'New York'},
            :pagination => '32 pp.',
          }
        }
      )
      reference.pages_in.should == 'In pp. 32-33:'
      reference.nested_reference.authors.first.name.should == 'Nested author'
      reference.nested_reference.title.should  == 'Nested title'
      reference.nested_reference.publisher.name  == 'Wiley'
      reference.nested_reference.pagination.should == '32 pp.'
    end

    it "should set the nested citation year to the outer citation year (minus the letter)" do
      reference = NestedReference.import(
        { :authors => [Factory :author], :citation_year => '2010a', :title => 'awdf',
          :source_reference_id => Factory(:ward_reference), :source_reference_type => 'WardReference',
        }, {:authors => ['Nested author'], :title => 'Nested title', :pages_in => 'In pp. 32-33:',
          :book => { :publisher => {:name => 'Wiley', :place => 'New York'}, :pagination => '32 pp.', } })

      reference.nested_reference.citation_year.should == '2010'
    end
  end

  describe "validation" do
    before do
      @reference = NestedReference.new :title => 'asdf', :authors => [Factory(:author)], :citation_year => '2010',
        :nested_reference => Factory(:reference), :pages_in => 'Pp 2 in:'
    end
    it "should be valid with the attributes given above" do
      @reference.should be_valid
    end
    it "should not be valid without a nested reference" do
      @reference.nested_reference = nil
      @reference.should_not be_valid
    end
    it "should not be valid without a pages in" do
      @reference.pages_in = nil
      @reference.should_not be_valid
    end
  end


  #describe "citation_string" do
    #it "should format a citation_string" do
      #publisher = Publisher.create! :name => "Wiley", :place => 'New York'
      #reference = BookReference.new :title => 'asdf', :publisher => publisher, :pagination => '32 pp.'
      #reference.citation_string.should == 'New York: Wiley, 32 pp.'
    #end
    #it "should format a citation_string correctly if the publisher doesn't have a place" do
      #publisher = Publisher.create! :name => "Wiley"
      #reference = BookReference.new :title => 'asdf', :publisher => publisher, :pagination => '32 pp.'
      #reference.citation_string.should == 'Wiley, 32 pp.'
    #end
  #end

end
