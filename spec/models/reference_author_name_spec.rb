require 'spec_helper'

describe ReferenceAuthorName do

  describe "Versioning" do
    it "should record versions" do
      with_versioning do
        reference_author_name = FactoryGirl.create :reference_author_name
        expect(reference_author_name.versions.last.event).to eq('create')
      end
    end
  end

end
