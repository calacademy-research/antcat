require "spec_helper"

describe Taxa::AnyNonTaxtReferences do
  describe "#call" do
    subject { described_class.new(atta) }

    let!(:atta) { create_genus 'Atta' }
    let!(:eciton) { create_genus 'Eciton' }

    before { eciton.update_attribute :type_taxt, "{tax #{atta.id}}" }

    context "when taxon has non-taxt references" do
      before { eciton.update_attribute :homonym_replaced_by, atta }

      it { expect(subject.call).to be true }
    end

    context "when taxon has no non-taxt references" do
      it { expect(subject.call).to be false }
    end
  end
end
