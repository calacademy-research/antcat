require 'spec_helper'

describe ReferenceSection do
  describe "Versioning" do
    it "should record versions" do
      with_versioning do
        reference_section = create :reference_section
        expect(reference_section.versions.last.event).to eq 'create'
      end
    end
  end
end
