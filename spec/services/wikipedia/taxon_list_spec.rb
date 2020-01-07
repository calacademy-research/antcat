require 'rails_helper'

describe Wikipedia::TaxonList do
  describe "#call" do
    context 'when taxon is a genus' do
      let!(:taxon) { create :genus }
      let!(:species_2) { create :species, name_string: "Atta mexicana", genus: taxon }
      let!(:species_1) { create :species, :fossil, name_string: "Atta cephalotes", genus: taxon }

      it "returns a wiki-formatted species list" do
        expect(described_class[taxon]).to eq <<~STR
          |diversity_link = #Species
          |diversity = 2 species
          |diversity_ref = #{Wikipedia::CiteTemplate[taxon]}

          ==Species==
          {{div col||25em}}
          * †''[[Atta cephalotes]]'' <small>#{species_1.author_citation}</small>
          * ''[[Atta mexicana]]'' <small>#{species_2.author_citation}</small>
          {{div col end}}
        STR
      end
    end
  end
end
