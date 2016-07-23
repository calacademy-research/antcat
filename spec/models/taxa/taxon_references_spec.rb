require 'spec_helper'

describe Taxon do
  describe "#references" do
    it "should have no references, if alone" do
      taxon = create_genus
      expect(taxon.references.size).to eq 0
    end

    describe "references in Taxon fields" do
      it "should have a reference if it's a taxon's genus" do
        genus = create_genus
        species = create_species genus: genus
        expect(genus.references).to match_array [
          {table: 'taxa', field: :genus_id, id: species.id},
        ]
      end

      it "should have a reference if it's a taxon's subfamily" do
        genus = create_genus
        expect(genus.subfamily.references).to match_array [
          {table: 'taxa', field: :subfamily_id, id: genus.id},
          {table: 'taxa', field: :subfamily_id, id: genus.tribe.id},
        ]
      end
    end

    describe "references in taxt" do
      it "returns references in taxt" do
        atta = create_genus 'Atta'
        eciton = create_genus 'Eciton'
        eciton.update_attribute :type_taxt, "{tax #{atta.id}}"
        expect(atta.references).to match_array [
          {table: 'taxa', field: :type_taxt, id: eciton.id},
        ]
      end

      it "doesn't return references in its own taxt" do
        eciton = create_genus 'Eciton'
        eciton.update_attribute :type_taxt, "{tax #{eciton.id}}"
        expect(eciton.references).to be_empty
      end
    end

    describe "Reference in its authorship taxt" do
      it "should not consider this an external reference" do
        eciton = create_genus 'Eciton'
        eciton.protonym.authorship.update_attribute :notes_taxt, "{tax #{eciton.id}}"
        expect(eciton.references).to be_empty
      end
    end

    describe "references as synonym" do
      it "should work" do
        atta = create_genus 'Atta'
        eciton = create_genus 'Eciton'
        eciton.extend TaxonSynonymsMonkeyPatch
        eciton.become_junior_synonym_of atta
        expect(atta.references).to match_array [
          {table: 'synonyms', field: :senior_synonym_id, id: eciton.id},
        ]
        expect(eciton.references).to match_array [
          {table: 'synonyms', field: :junior_synonym_id, id: atta.id},
        ]
      end
    end
  end

  describe "#nontaxt_references" do
    it "returns only nontaxt references" do
      atta = create_genus 'Atta'
      eciton = create_genus 'Eciton'
      eciton.update_attribute :type_taxt, "{tax #{atta.id}}"
      eciton.update_attribute :homonym_replaced_by, atta
      expect(atta.nontaxt_references).to match_array [
        {table: 'taxa', field: :homonym_replaced_by_id, id: eciton.id},
      ]
    end
  end
end
