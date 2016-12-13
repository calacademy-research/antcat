require 'spec_helper'

describe Reference do
  let(:reference) { create :article_reference }

  describe "#reference_references" do
    it "has no references, if alone" do
      expect(reference.send(:reference_references).size).to eq 0
    end

    describe "References in reference fields" do
      it "has a reference if it's a protonym's authorship's reference" do
        eciton = create_genus 'Eciton'
        eciton.protonym.authorship.update! reference_id: reference.id
        expect(reference.send :reference_references).to match_array [
          { table: 'citations', field: :reference_id, id: eciton.protonym.authorship.id },
        ]
      end
    end

    describe "References in taxt" do
      it "returns references in taxt" do
        eciton = create_genus 'Eciton'
        eciton.update_attribute :type_taxt, "{ref #{reference.id}}"
        expect(reference.send :reference_references).to match_array [
          { table: 'taxa', field: :type_taxt, id: eciton.id },
        ]
      end
    end
  end
end
