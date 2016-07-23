require 'spec_helper'

describe ReferenceAuthorName do
  describe "versioning" do
    it "records versions" do
      with_versioning do
        reference_author_name = create :reference_author_name
        expect(reference_author_name.versions.last.event).to eq 'create'
      end
    end
  end
end
