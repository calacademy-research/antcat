# frozen_string_literal: true

require 'rails_helper'

describe Exporters::Antweb::History::ProtonymSynopsis::TypeNameLine do
  include TestLinksHelpers

  describe "#call" do
    context "when taxon has a type name" do
      let(:type_species) { create :species, name_string: 'Atta major' }
      let(:taxon) { create :genus }
      let(:type_name) { create :type_name, :by_subsequent_designation_of, taxon: type_species, pages: '1' }

      before do
        taxon.protonym.update!(type_name: type_name)
      end

      it "links the type name" do
        reference_link = antweb_reference_link(type_name.reference)

        expect(described_class[taxon]).
          to eq %(Type-species: #{antweb_taxon_link(type_species)}, by subsequent designation of #{reference_link}: 1.)
      end
    end

    context "when taxon does not have a type name" do
      let(:taxon) { create :genus }

      specify { expect(described_class[taxon]).to eq "" }
    end
  end
end
