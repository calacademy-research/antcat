require 'spec_helper'

describe DuplicateReferencesFinder do

  it "should populate duplicate_references" do
    author_name = Factory :author_name
    target = Factory :reference, :author_names => [author_name]
    duplicate = Factory :reference, :author_names => [author_name]
    not_a_duplicate = Factory :reference, :author_names => [author_name]
    Reference.should_receive(:all).and_return [target, duplicate, not_a_duplicate]
    target.should_not_receive(:<=>).with(target)
    target.should_receive(:<=>).with(duplicate).and_return 0.20
    target.should_receive(:<=>).with(not_a_duplicate).and_return 0.10
    duplicate.should_not_receive(:<=>).with(duplicate)
    duplicate.should_not_receive(:<=>).with(target)
    duplicate.should_receive(:<=>).with(not_a_duplicate).and_return 0.00
    not_a_duplicate.should_not_receive(:<=>).with(not_a_duplicate)
    not_a_duplicate.should_receive(:<=>).with(target).and_return 0.00
    not_a_duplicate.should_receive(:<=>).with(duplicate).and_return 0.00

    DuplicateReferencesFinder.new.find_duplicates

    DuplicateReference.count.should == 1
    duplicate_reference = DuplicateReference.first
    duplicate_reference.reference.should == target
    duplicate_reference.duplicate.should == duplicate
    duplicate_reference.similarity.should == 0.20
  end

end
