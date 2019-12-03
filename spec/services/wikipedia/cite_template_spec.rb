require 'rails_helper'

describe Wikipedia::CiteTemplate do
  let(:species) { create :species, name_string: "Atta texana" }

  describe "#call" do
    context "when without with_ref_tag" do
      include ActiveSupport::Testing::TimeHelpers

      it "outputs a Template:AntCat" do
        expected = "{{AntCat|#{species.id}|''Atta texana''|2016|accessdate=2 November 2016}}"

        travel_to(Time.zone.parse('2016 November 2')) do
          expect(described_class[species]).to eq expected
        end
      end

      it "handles fossils" do
        species.fossil = true
        expect(described_class[species]).to include "†"
      end
    end

    context "when with_ref_tag" do
      it "wraps the output in a named <ref> tag" do
        results = described_class[species, with_ref_tag: true]

        expect(results).to include '<ref name="AntCat">'
        expect(results).to include "''Atta texana''"
        expect(results).to include "</ref>"
      end
    end
  end
end
