require 'spec_helper'

describe Reference do

  describe "References" do
    it "should have no references, if alone" do
      reference = FactoryGirl.create :article_reference
      expect(reference.reference_references.size).to eq(0)
    end

    describe "References in reference fields" do
      it "should have a reference if it's a protonym's authorship's reference" do
        reference = FactoryGirl.create :article_reference
        eciton = create_genus 'Eciton'
        eciton.protonym.authorship.update_attributes! reference_id: reference.id
        expect(reference.reference_references).to match_array([
          {table: 'citations', field: :reference_id, id: eciton.protonym.authorship.id},
        ])
      end
    end

    describe "References in taxt" do
      it "should return references in taxt" do
        reference = FactoryGirl.create :article_reference
        eciton = create_genus 'Eciton'
        eciton.update_attribute :type_taxt, "{ref #{reference.id}}"
        expect(reference.reference_references).to match_array([
          {table: 'taxa', field: :type_taxt, id: eciton.id},
        ])
      end
    end

  end
end
