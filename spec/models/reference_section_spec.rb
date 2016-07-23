require 'spec_helper'

describe ReferenceSection do
  describe "versioning" do
    it "records versions" do
      with_versioning do
        reference_section = create :reference_section
        expect(reference_section.versions.last.event).to eq 'create'
      end
    end
  end
end
