require 'spec_helper'

describe TaxonForm do
  before do
    fake_current_user
  end

  describe "#save" do
    describe "creating a changes" do
      context "when a taxon is added" do
        let!(:taxon) { build :subfamily }

        it "creates a change pointing to the version of taxon" do
          expect do
            with_versioning { described_class.new(taxon, genus_params).save }
          end.to change { Change.count }.from(0).to(1)
          expect(Change.last.taxon).to eq taxon.versions.last.item
        end
      end

      context "when a taxon is edited" do
        let(:genus) { create :family }

        it "creates a change for the edit" do
          expect do
            with_versioning { described_class.new(genus, genus_params).save }
          end.to change { Change.count }.from(0).to(1)
          expect(Change.last.change_type).to eq 'update'
        end
      end
    end
  end
end

def taxon_params
  HashWithIndifferentAccess.new(
    name_attributes: {},
    status: Status::VALID,
    protonym_attributes: {
      name_attributes:  {},
      authorship_attributes: {
        reference_id: create(:article_reference).id
      }
    }
  )
end

def genus_params
  params = taxon_params
  params[:name_attributes][:id] = create(:genus_name).id
  params[:protonym_attributes][:name_attributes][:id] = create(:genus_name).id
  params[:type_name_attributes] = { id: create(:species_name).id }
  params
end
