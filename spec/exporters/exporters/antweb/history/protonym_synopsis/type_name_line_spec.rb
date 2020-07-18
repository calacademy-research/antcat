# frozen_string_literal: true

require 'rails_helper'

describe Exporters::Antweb::History::ProtonymSynopsis::TypeNameLine do
  include AntwebTestLinksHelpers

  describe "#call" do
    context "when protonym has a type name" do
      let(:type_species) { create :species, name_string: 'Atta major' }
      let(:type_name) { create :type_name, :by_subsequent_designation_of, taxon: type_species, pages: '1' }
      let(:protonym) { create :protonym, type_name: type_name }

      it "links the type name" do
        reference_link = antweb_reference_link(type_name.reference)

        expect(described_class[protonym]).
          to eq %(Type-species: #{antweb_taxon_link(type_species)}, by subsequent designation of #{reference_link}: 1.)
      end
    end

    context "when protonym does not have a type name" do
      let(:protonym) { create :protonym }

      specify { expect(described_class[protonym]).to eq "" }
    end
  end
end
