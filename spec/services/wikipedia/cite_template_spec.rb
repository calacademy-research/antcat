require 'rails_helper'

describe Wikipedia::CiteTemplate do
  include ActiveSupport::Testing::TimeHelpers

  describe "#call" do
    let(:taxon) { create :species, name_string: "Atta texana" }

    it "returns a wiki-formatted Template:AntCat" do
      travel_to(Time.zone.parse('2016 November 2')) do
        expect(described_class[taxon]).
          to eq %(<ref name="AntCat">{{AntCat|#{taxon.id}|''Atta texana''|2016|accessdate=2 November 2016}}</ref>)
      end
    end

    context 'when taxon is fossil' do
      let(:taxon) { create :species, :fossil, name_string: "Atta texana" }

      it 'includes a dagger' do
        expect(described_class[taxon]).to include "†''Atta texana''"
      end
    end
  end
end
