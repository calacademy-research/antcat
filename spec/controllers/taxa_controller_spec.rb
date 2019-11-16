require 'spec_helper'

describe TaxaController do
  let(:user) { create :user, :editor }

  describe "forbidden actions" do
    context "when signed in as a user" do
      before { sign_in create(:user) }

      specify { expect(get(:new)).to have_http_status :forbidden }
      specify { expect(get(:edit, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:create)).to have_http_status :forbidden }
      specify { expect(put(:update, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "POST create" do
    before do
      sign_in user
    end

    let(:authorship_reference) { create :article_reference }
    let(:base_params) do
      HashWithIndifferentAccess.new(
        status: Status::VALID,
        protonym_attributes: {
          authorship_attributes: {
            reference_id: authorship_reference.id,
            pages: '99'
          }
        }
      )
    end

    context 'with valid params' do
      context "when rank is genus" do
        let(:parent) { create :subfamily }
        let(:genus_params) do
          {
            parent_id: parent.id,
            rank_to_create: "genus",
            taxon_name_string: "Atta",
            protonym_name_string: "Atta"
          }
        end

        describe "most minimal amount of params" do
          it "creates a record" do
            params = genus_params.merge(taxon: base_params)
            expect { post :create, params: params }.to change { Taxon.count }.by(1)

            taxon = Taxon.last
            expect(taxon.subfamily).to eq parent
            expect(taxon).to be_a Genus
          end
        end

        describe "basic taxon attributes" do
          let(:type_taxon) { create :species }
          let(:taxon_params) do
            base_params.deep_merge(
              incertae_sedis_in: Taxon::INCERTAE_SEDIS_IN_FAMILY,
              fossil: true,
              original_combination: true,
              collective_group_name: true,
              unresolved_homonym: true,
              ichnotaxon: true,
              hong: true,
              headline_notes_taxt: "headline notes taxt",
              type_taxt: "type taxt",
              type_taxon_id: type_taxon.id
            )
          end

          specify do
            post :create, params: genus_params.merge(taxon: taxon_params)

            taxon = Taxon.last

            expect(taxon.status).to eq taxon_params[:status]
            expect(taxon.incertae_sedis_in).to eq taxon_params[:incertae_sedis_in]
            expect(taxon.fossil).to eq taxon_params[:fossil]
            expect(taxon.original_combination).to eq taxon_params[:original_combination]
            expect(taxon.collective_group_name).to eq taxon_params[:collective_group_name]
            expect(taxon.unresolved_homonym).to eq taxon_params[:unresolved_homonym]
            expect(taxon.ichnotaxon).to eq taxon_params[:ichnotaxon]
            expect(taxon.hong).to eq taxon_params[:hong]
            expect(taxon.headline_notes_taxt).to eq taxon_params[:headline_notes_taxt]
            expect(taxon.type_taxt).to eq taxon_params[:type_taxt]
            expect(taxon.type_taxon_id).to eq taxon_params[:type_taxon_id]
          end
        end

        describe "protonym attributes" do
          let(:taxon_params) do
            base_params.deep_merge(
              protonym_attributes: {
                fossil: true,
                sic: true,
                locality: "San Francisco",
                primary_type_information_taxt: "primary type information",
                secondary_type_information_taxt: "secondary type information",
                type_notes_taxt: "type notes",
                authorship_attributes: {
                  pages: "21 pp.",
                  forms: "w.",
                  notes_taxt: "notes taxt"
                }
              }
            )
          end

          it 'sets protonym_attributes' do
            post :create, params: genus_params.merge(taxon: taxon_params)

            protonym = Taxon.last.protonym
            protonym_attributes = taxon_params[:protonym_attributes]

            expect(protonym.fossil).to eq protonym_attributes[:fossil]
            expect(protonym.sic).to eq protonym_attributes[:sic]
            expect(protonym.locality).to eq protonym_attributes[:locality]
            expect(protonym.primary_type_information_taxt).to eq protonym_attributes[:primary_type_information_taxt]
            expect(protonym.secondary_type_information_taxt).to eq protonym_attributes[:secondary_type_information_taxt]
            expect(protonym.type_notes_taxt).to eq protonym_attributes[:type_notes_taxt]
          end

          it 'sets authorship_attributes' do
            post :create, params: genus_params.merge(taxon: taxon_params)

            authorship = Taxon.last.protonym.authorship
            authorship_attributes = taxon_params[:protonym_attributes][:authorship_attributes]

            expect(authorship.pages).to eq authorship_attributes[:pages]
            expect(authorship.forms).to eq authorship_attributes[:forms]
            expect(authorship.notes_taxt).to eq authorship_attributes[:notes_taxt]
          end

          context 'when `protonym_id` is supplied' do # rubocop:disable RSpec/NestedGroups
            let(:protonym) { create :protonym }

            it 'uses the ID and ignores the protonym attributes' do
              post :create, params: genus_params.merge(taxon: taxon_params.merge(protonym_id: protonym.id))
              expect(Taxon.last.protonym.id).to eq protonym.id
            end
          end
        end

        describe "setting `current_valid_taxon`" do
          let(:current_valid_taxon) { create :genus }
          let(:taxon_params) do
            base_params.deep_merge(
              status: Status::SYNONYM,
              current_valid_taxon_id: current_valid_taxon.id
            )
          end

          specify do
            post :create, params: genus_params.merge(taxon: taxon_params)
            expect(Taxon.last.current_valid_taxon).to eq current_valid_taxon
          end
        end
      end

      context 'with non-matching name type' do
        let(:parent) { create :subfamily }
        let(:genus_params) do
          {
            parent_id: parent.id,
            rank_to_create: "genus",
            taxon_name_string: "Attini",
            protonym_name_string: "Atta"
          }
        end

        it "does not create a record" do
          params = genus_params.merge(taxon: base_params)
          expect { post :create, params: params }.to_not change { Taxon.count }

          taxon_assign = assigns(:taxon) # TODO: Hmm.
          expect(taxon_assign.errors.empty?).to eq false
          expect(taxon_assign.errors[:base]).to eq ["Rank (`Genus`) and name type (`TribeName`) must match."]
        end
      end
    end
  end

  describe "PUT update" do
    let!(:taxon) { create :subfamily, family: create(:family) }
    let!(:taxon_params) do
      {
        status:  Status::EXCLUDED_FROM_FORMICIDAE
      }
    end

    before { sign_in user }

    it 'updates the taxon' do
      put(:update, params: { id: taxon.id, taxon: taxon_params })

      taxon.reload
      expect(taxon.status).to eq taxon_params[:status]
    end

    it 'creates an activity' do
      expect { put(:update, params: { id: taxon.id, taxon: taxon_params, edit_summary: 'Fix status' }) }.
        to change { Activity.where(action: :update, trackable: taxon).count }.by(1)

      activity = Activity.last
      expect(activity.edit_summary).to eq "Fix status"
    end
  end

  describe "DELETE destroy" do
    let!(:taxon) { create :subfamily, family: create(:family) }

    before { sign_in user }

    it 'deletes the taxon' do
      expect { delete(:destroy, params: { id: taxon.id }) }.to change { Taxon.count }.by(-1)
    end

    it 'creates an activity' do
      expect { delete(:destroy, params: { id: taxon.id, edit_summary: 'Duplicate' }) }.
        to change { Activity.where(action: :destroy, trackable: taxon).count }.by(1)

      activity = Activity.last
      expect(activity.edit_summary).to eq "Duplicate"
    end
  end
end
