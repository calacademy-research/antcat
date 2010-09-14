require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WardReference do
  it "belongs to a reference" do
    ward_reference = WardReference.create!
    ward_reference.reference.should be_nil
    reference = Factory :reference
    ward_reference.update_attribute :reference, reference
    ward_reference.reference.should == reference
  end
end
