require 'spec_helper'

describe Taxon do
  describe "#references" do
    let!(:atta) { create_genus 'Atta' }

    it "has no references, if alone" do
      expect(atta.references.size).to eq 0
    end

    describe "references in Taxon fields" do
      it "has a reference if it's a taxon's genus" do
        species = create_species genus: atta
        expect(atta.references).to match_array [
          { table: 'taxa', field: :genus_id, id: species.id }
        ]
      end

      it "has a reference if it's a taxon's subfamily" do
        expect(atta.subfamily.references).to match_array [
          { table: 'taxa', field: :subfamily_id, id: atta.id },
          { table: 'taxa', field: :subfamily_id, id: atta.tribe.id }
        ]
      end
    end

    describe "references in taxt" do
      it "returns references in taxt" do
        eciton = create_genus 'Eciton'
        eciton.update_attribute :type_taxt, "{tax #{atta.id}}"

        expect(atta.references).to match_array [
          { table: 'taxa', field: :type_taxt, id: eciton.id }
        ]
      end

      it "doesn't return references in its own taxt" do
        atta.update_attribute :type_taxt, "{tax #{atta.id}}"
        expect(atta.references).to be_empty
      end
    end

    describe "Reference in its authorship taxt" do
      it "doesn't consider this an external reference" do
        atta.protonym.authorship.update_attribute :notes_taxt, "{tax #{atta.id}}"
        expect(atta.references).to be_empty
      end
    end

    describe "references as synonym" do
      it "works" do
        eciton = create_genus 'Eciton'
        # Previously `eciton.become_junior_synonym_of atta`
        Synonym.create! junior_synonym: eciton, senior_synonym: atta

        expect(atta.references).to match_array [
          { table: 'synonyms', field: :senior_synonym_id, id: eciton.id }
        ]
        expect(eciton.references).to match_array [
          { table: 'synonyms', field: :junior_synonym_id, id: atta.id }
        ]
      end
    end
  end

  describe "non-taxt references" do
    let!(:atta) { create_genus 'Atta' }

    context "taxon has non-taxt references" do
      let!(:eciton) { create_genus 'Eciton' }
      before do
        eciton.update_attribute :type_taxt, "{tax #{atta.id}}"
        eciton.update_attribute :homonym_replaced_by, atta
      end

      describe "#nontaxt_references" do
        it "returns only non-taxt references" do
          expect(atta.nontaxt_references).to match_array [
            { table: 'taxa', field: :homonym_replaced_by_id, id: eciton.id }
          ]
        end
      end

      describe "#any_nontaxt_references?" do
        it { expect(atta.any_nontaxt_references?).to be true }
      end
    end

    context "taxon has no non-taxt references" do
      describe "#nontaxt_references" do
        it { expect(atta.nontaxt_references).to be_empty }
      end

      describe "#any_nontaxt_references?" do
        it { expect(atta.any_nontaxt_references?).to be_falsey }
      end
    end
  end
end
