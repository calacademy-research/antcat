require 'spec_helper'

describe Place do
  it { should validate_presence_of(:name) }

  describe "versioning" do
    it "records versions" do
      with_versioning do
        place = create :place
        expect(place.versions.last.event).to eq 'create'
      end
    end
  end
end
