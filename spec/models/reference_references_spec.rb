# coding: UTF-8
require 'spec_helper'

describe Reference do

  describe "References" do
    it "should have no references, if alone" do
      reference = FactoryGirl.create :article_reference
      reference.should have(0).references
    end

    describe "References in reference fields" do
      it "should have a reference if it's a protonym's authorship's reference" do
        genus = create_genus
        species = create_species genus: genus
        genus.references.should =~ [
          {table: 'taxa', field: :genus_id, id: species.id},
        ]
        reference = FactoryGirl.create :article_reference
        eciton = create_genus 'Eciton'
        eciton.protonym.authorship.update_attributes! reference_id: reference.id
        reference.references.should =~ [
          {table: 'citations', field: :reference_id, id: eciton.id},
        ]
      end
    end

    describe "References in taxt" do
      it "should return references in taxt" do
        reference = FactoryGirl.create :article_reference
        eciton = create_genus 'Eciton'
        eciton.update_attribute :type_taxt, "{ref #{reference.id}}"
        reference.references.should =~ [
          {table: 'taxa', field: :type_taxt, id: eciton.id},
        ]
      end
    end

  end
end
