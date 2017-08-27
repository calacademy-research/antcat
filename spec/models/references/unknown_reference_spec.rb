require 'spec_helper'

describe UnknownReference do
  it { is_expected.to validate_presence_of :year }
  it { is_expected.to validate_presence_of :citation }

  describe "entering a newline in the citation" do
    it "strips the newline" do
      reference = create :unknown_reference
      reference.title = "A\nB"
      reference.citation = "A\nB"
      reference.save!

      expect(reference.title).to eq "A B"
      expect(reference.citation).to eq "A B"
    end
  end
end
