# frozen_string_literal: true

require 'rails_helper'

describe Exporters::Antweb::History::ProtonymSynopsis::TypeFields do
  include AntwebTestLinksHelpers

  describe "#call" do
    context "when protonym has type information" do
      let(:taxon) { create :genus }
      let(:protonym) do
        create :protonym,
          primary_type_information_taxt: "uno {tax #{taxon.id}}",
          secondary_type_information_taxt: "dos {tax #{taxon.id}}",
          type_notes_taxt: "tres {tax #{taxon.id}}"
      end

      it "links the type name" do
        expect(described_class[protonym]).to eq(
          "Primary type information: uno #{antweb_taxon_link(taxon)} " \
          "Secondary type information: dos #{antweb_taxon_link(taxon)} " \
          "Type notes: tres #{antweb_taxon_link(taxon)}"
        )
      end
    end

    context "when protonym has no type information" do
      let(:protonym) { create :protonym }

      specify { expect(described_class[protonym]).to eq "" }
    end
  end
end
