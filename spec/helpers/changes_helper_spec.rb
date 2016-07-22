require 'spec_helper'

describe ChangesHelper do

  describe "Formatting attributes" do
    it "should concatenate attributes into a comma-separated list" do
      genus = create_genus hong: true, nomen_nudum: true
      expect(helper.format_attributes(genus)).to eq 'Hong, <i>nomen nudum</i>'
    end
    it "should concatenate protonym attributes into a comma-separated list" do
      protonym = create :protonym, sic: true, fossil: true
      genus = create_genus protonym: protonym
      expect(helper.format_protonym_attributes(genus)).to eq 'Fossil, <i>sic</i>'
    end
    it "should include the one type attribute" do
      genus = create_genus type_fossil: true
      expect(helper.format_type_attributes(genus)).to eq 'Fossil'
    end
  end

end
