require 'spec_helper'

describe Ward::Reference do
  it "belongs to a reference" do
    ward_reference = Ward::Reference.create!
    ward_reference.reference.should be_nil
    reference = Factory :reference
    ward_reference.update_attribute :reference, reference
    ward_reference.reference.should == reference
  end

  it "should not truncate long fields" do
    Ward::Reference.create!(:authors => 'a' * 1000, :citation => 'c' * 2000, :notes => 'n' * 1500, :taxonomic_notes => 't' * 1700, :title => 'i' * 1876)
    reference = Ward::Reference.first
    reference.authors.length.should == 1000
    reference.citation.length.should == 2000
    reference.notes.length.should == 1500
    reference.taxonomic_notes.length.should == 1700
    reference.title.length.should == 1876
  end

end
