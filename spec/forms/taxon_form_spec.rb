require 'spec_helper'

describe TaxonForm do
  describe "#save" do
    let(:user) { create :user }

    describe "creating a changes" do
      context "when a taxon is added", :versioning do
        let!(:taxon) do
          taxon = Subfamily.new
          taxon.build_name
          taxon.build_protonym
          taxon.protonym.build_name
          taxon.protonym.build_authorship
          taxon
        end
        let(:taxon_params) do
          {
            status: Status::VALID,
            protonym_attributes: {
              authorship_attributes: {
                reference_id: create(:article_reference).id,
                pages: '99'
              }
            }
          }
        end

        it "creates a change pointing to the version of taxon" do
          expect do
            described_class.new(
              taxon, taxon_params, taxon_name_string: "Antinae", protonym_name_string: "Antinae", user: user
            ).save
          end.to change { Change.count }.from(0).to(1)

          last_change = Change.last
          expect(last_change.change_type).to eq 'create'
          expect(last_change.taxon).to eq taxon
          expect(last_change.taxon).to eq taxon.versions.last.item
          expect(last_change.user).to eq user
        end
      end

      context "when a taxon is edited" do
        let(:taxon) { create :family }
        let(:taxon_params) { { status: Status::UNAVAILABLE } }

        it "creates a change for the edit" do
          expect { described_class.new(taxon, taxon_params, user: user).save }.
            to change { Change.count }.from(0).to(1)

          last_change = Change.last
          expect(last_change.change_type).to eq 'update'
          expect(last_change.taxon).to eq taxon
          expect(last_change.user).to eq user
        end
      end
    end
  end
end
