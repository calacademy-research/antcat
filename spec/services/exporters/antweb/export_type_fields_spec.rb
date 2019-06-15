require "spec_helper"

describe Exporters::Antweb::ExportTypeFields do
  describe "#call" do
    context "when protonym has type information" do
      let(:taxon) { create :genus }
      let(:protonym) do
        create :protonym,
          primary_type_information_taxt: "uno {tax #{taxon.id}}",
          secondary_type_information_taxt: "dos {tax #{taxon.id}}",
          type_notes_taxt: "tres {tax #{taxon.id}}"
      end
      let(:taxon_link) { %(<a href="http://www.antcat.org/catalog/#{taxon.id}"><i>#{taxon.name_cache}</i></a>) }

      it "links the type name" do
        expect(described_class[protonym]).to eq(
          "Primary type information: uno #{taxon_link}. " +
          "Secondary type information: dos #{taxon_link}. " +
          "Type notes: tres #{taxon_link}."
        )
      end
    end

    context "when protonym has no type information" do
      let(:protonym) { create :protonym }

      specify { expect(described_class[protonym]).to eq "" }
    end
  end
end
