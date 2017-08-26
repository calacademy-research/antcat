require 'spec_helper'

describe ChangesHelper do
  describe "#format_attributes" do
    let(:genus) { create_genus hong: true, nomen_nudum: true }

    it "concatenates attributes into a comma-separated list" do
      expect(helper.format_attributes(genus)).to eq 'Hong, <i>nomen nudum</i>'
    end
  end

  describe "#format_protonym_attributes" do
    let(:genus) { create_genus protonym: create(:protonym, sic: true, fossil: true) }

    it "concatenates protonym attributes into a comma-separated list" do
      expect(helper.format_protonym_attributes(genus)).to eq 'Fossil, <i>sic</i>'
    end
  end
end
