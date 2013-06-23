# coding: UTF-8
require 'spec_helper'

describe Taxon do

  describe "References" do
    it "should have no references, if alone" do
      taxon = create_genus
      taxon.should have(0).references
    end

    describe "references in Taxon fields" do
      it "should have a reference if it's a taxon's genus" do
        genus = create_genus
        species = create_species genus: genus
        genus.references.should =~ [
          {table: 'taxa', field: :genus_id, id: species.id},
        ]
      end
      it "should have a reference if it's a taxon's subfamily" do
        genus = create_genus
        genus.subfamily.references.should =~ [
          {table: 'taxa', field: :subfamily_id, id: genus.id},
          {table: 'taxa', field: :subfamily_id, id: genus.tribe.id},
        ]
      end
    end

    describe "references in taxt" do
      it "should return references in taxt" do
        atta = create_genus 'Atta'
        eciton = create_genus 'Eciton'
        eciton.update_attribute :type_taxt, "{tax #{atta.id}}"
        atta.references.should =~ [
          {table: 'taxa', field: :type_taxt, id: eciton.id},
        ]
      end
      it "should not return references in its own taxt" do
        eciton = create_genus 'Eciton'
        eciton.update_attribute :type_taxt, "{tax #{eciton.id}}"
        eciton.references.should be_empty
      end

    end

    describe "Reference in its authorship taxt" do
      it "should not consider this an external reference" do
        eciton = create_genus 'Eciton'
        eciton.protonym.authorship.update_attribute :notes_taxt, "{tax #{eciton.id}}"
        eciton.references.should be_empty
      end
    end

    describe "references as synonym" do
      it "should work" do
        atta = create_genus 'Atta'
        eciton = create_genus 'Eciton'
        eciton.become_junior_synonym_of atta
        atta.references.should =~ [
          {table: 'synonyms', field: :senior_synonym_id, id: eciton.id},
        ]
        eciton.references.should =~ [
          {table: 'synonyms', field: :junior_synonym_id, id: atta.id},
        ]
      end
    end

    describe "Nontaxt references" do
      it "should return only nontaxt references" do
        atta = create_genus 'Atta'
        eciton = create_genus 'Eciton'
        eciton.update_attribute :type_taxt, "{tax #{atta.id}}"
        eciton.update_attribute :homonym_replaced_by, atta
        atta.nontaxt_references.should =~ [
          {table: 'taxa', field: :homonym_replaced_by_id, id: eciton.id},
        ]
      end
    end
  end

end
