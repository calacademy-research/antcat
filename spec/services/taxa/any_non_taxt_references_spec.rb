require "spec_helper"

describe Taxa::AnyNonTaxtReferences do
  describe "#call" do
    let!(:taxon) { create :family }
    let!(:other_taxon) { create :family, :homonym, type_taxt: "{tax #{taxon.id}}" }

    context "when taxon has non-taxt references" do
      before { other_taxon.update homonym_replaced_by: taxon }

      it { expect(described_class[taxon]).to be true }
    end

    context "when taxon has no non-taxt references" do
      it { expect(described_class[taxon]).to be false }
    end
  end
end
