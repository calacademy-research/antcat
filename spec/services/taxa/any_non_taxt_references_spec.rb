require "spec_helper"

describe Taxa::AnyNonTaxtReferences do
  describe "#call" do
    subject { described_class.new(taxon) }

    let!(:taxon) { create :family }
    let!(:other_taxon) { create :family, :homonym, type_taxt: "{tax #{taxon.id}}" }

    context "when taxon has non-taxt references" do
      before { other_taxon.update homonym_replaced_by: taxon }

      it { expect(subject.call).to be true }
    end

    context "when taxon has no non-taxt references" do
      it { expect(subject.call).to be false }
    end
  end
end
