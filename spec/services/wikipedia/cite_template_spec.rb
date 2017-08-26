require "spec_helper"

describe Wikipedia::CiteTemplate do
  let(:species) { create_species "Atta texana" }

  describe ".generate" do
    it "outputs a Template:AntCat" do
      travel_to Time.new(2016, 11, 2, 20)

      expected = "{{AntCat|#{species.id}|''Atta texana''|2016|accessdate=2 November 2016}}"
      expect(described_class.generate species).to eq expected
    end

    it "handles fossils" do
      species.fossil = true
      expect(described_class.generate species).to include "†"
    end
  end

  describe ".with_ref_tag" do
    it "wraps the output in a named <ref> tag" do
      results = described_class.with_ref_tag species

      expect(results).to include '<ref name="AntCat">'
      expect(results).to include "''Atta texana''"
      expect(results).to include "</ref>"
    end
  end
end
