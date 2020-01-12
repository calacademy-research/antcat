require 'rails_helper'

describe TaxonForm do
  describe "#save" do
    let(:user) { create :user }

    describe "creating a changes" do
      context "when taxon is created", :versioning do
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

        it "creates a 'create' `Change` for the taxon" do
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

      context "when taxon is updated" do
        let(:taxon) { create :family }
        let(:taxon_params) { { status: Status::UNAVAILABLE } }

        it "creates an 'update' `Change` for the taxon" do
          expect { described_class.new(taxon, taxon_params, user: user).save }.
            to change { Change.count }.from(0).to(1)

          last_change = Change.last
          expect(last_change.change_type).to eq 'update'
          expect(last_change.taxon).to eq taxon
          expect(last_change.user).to eq user
        end
      end
    end

    describe "#set_taxon_state_to_waiting" do
      context "when taxon is updated" do
        let(:taxon) { create :family, :old }
        let(:taxon_params) { { status: Status::UNAVAILABLE } }

        it "sets the review status to 'waiting'" do
          expect { described_class.new(taxon, taxon_params, user: user).save }.to change { taxon.reload.waiting? }.to(true)
        end
      end
    end

    describe "#remove_auto_generated" do
      context "when taxon is updated" do
        let!(:taxon) { create :family, auto_generated: true  }
        let(:taxon_params) { { status: Status::UNAVAILABLE } }

        it "sets `auto_generated` to false'" do
          expect { described_class.new(taxon, taxon_params, user: user).save }.
            to change { taxon.reload.auto_generated? }.from(true).to(false)
        end
      end
    end
  end
end
