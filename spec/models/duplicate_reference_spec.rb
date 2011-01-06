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

  describe 'resolving a duplicate reference' do

    describe 'replacing one reference with another' do
      it 'should replace the second references with the first' do
        ward = Factory :reference, :public_notes => 'Public notes'
        copy = Factory :reference
        nested = Factory :nested_reference, :nested_reference => copy
        DuplicateReference.merge ward.id, copy.id
        Reference.count.should == 2
        nested.reload.nested_reference.should == ward
        Reference.find(ward)
      end
    end

    describe 'fixing nested references' do
      it 'should replace the nested reference id with the good reference' do
        ward = Factory :reference, :public_notes => 'Public notes'
        copy = Factory :reference
        nested = Factory :nested_reference, :nested_reference => copy
        DuplicateReference.new(:reference => ward, :duplicate => copy).resolve
        Reference.count.should == 2
        nested.reload.nested_reference.should == ward
        Reference.find(ward)
      end
      it 'should just leave everything alone if the nested reference already points to the good reference' do
        ward = Factory :reference, :public_notes => 'Public notes'
        copy = Factory :reference
        nested = Factory :nested_reference, :nested_reference => ward
        DuplicateReference.new(:reference => ward, :duplicate => copy).resolve
        Reference.count.should == 2
        nested.reload.nested_reference.should == ward
        Reference.find(ward)
      end
    end

    describe 'choosing which one should be kept' do
      it "should bail out if it can't find the real one" do
        ward = Factory :reference
        copy = Factory :reference
        lambda {DuplicateReference.new(:reference => ward, :duplicate => copy).resolve}.should raise_error
      end
      describe 'choosing the one with a date' do
        it 'should pick the one with a date' do
          ward = Factory :reference, :date => '[1982.1.2]'
          copy = Factory :reference
          DuplicateReference.new(:reference => ward, :duplicate => copy).resolve
          Reference.count.should == 1
          Reference.first.should == ward
        end
      end
      describe 'choosing the one with public notes' do
        it 'should pick the one with public notes' do
          ward = Factory :reference, :public_notes => 'Public notes'
          copy = Factory :reference
          DuplicateReference.new(:reference => ward, :duplicate => copy).resolve
          Reference.count.should == 1
          Reference.first.should == ward
        end
        it 'should pick the one with public notes' do
          ward = Factory :reference
          copy = Factory :reference, :public_notes => 'Public notes'
          DuplicateReference.new(:reference => ward, :duplicate => copy).resolve
          Reference.count.should == 1
          Reference.first.should == copy
        end
      end
      describe 'choosing the one with a letter in its citation year' do
        it 'should pick the one with a letter in its citation year' do
          ward = Factory :reference, :citation_year => '2001'
          copy = Factory :reference, :citation_year => '2001b'
          DuplicateReference.new(:reference => ward, :duplicate => copy).resolve
          Reference.count.should == 1
          Reference.first.should == copy
        end
        it 'should pick the one with a letter in its citation year' do
          ward = Factory :reference, :citation_year => '2001b'
          copy = Factory :reference, :citation_year => '2001'
          DuplicateReference.new(:reference => ward, :duplicate => copy).resolve
          Reference.count.should == 1
          Reference.first.should == ward
        end
      end
    end
  end
end
