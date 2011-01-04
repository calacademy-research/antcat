require 'spec_helper'

describe DuplicateReference do
  it "has a reference and a duplicate" do
    target = Factory :reference
    duplicate = Factory :reference
    DuplicateReference.create! :reference => target, :duplicate => duplicate, :similarity => 0.5
    DuplicateReference.count.should == 1
    DuplicateReference.first.reference.should == target
    DuplicateReference.first.duplicate.should == duplicate
    DuplicateReference.first.similarity.should == 0.5
  end
end
