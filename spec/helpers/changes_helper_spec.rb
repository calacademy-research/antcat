require 'spec_helper'

describe ChangesHelper do
  describe "#format_attributes" do
    it "concatenates attributes into a comma-separated list" do
      genus = create_genus hong: true, nomen_nudum: true
      expect(helper.format_attributes(genus)).to eq 'Hong, <i>nomen nudum</i>'
    end
  end

  describe "#format_protonym_attributes" do
    it "concatenates protonym attributes into a comma-separated list" do
      protonym = create :protonym, sic: true, fossil: true
      genus = create_genus protonym: protonym
      expect(helper.format_protonym_attributes(genus)).to eq 'Fossil, <i>sic</i>'
    end
  end
end
