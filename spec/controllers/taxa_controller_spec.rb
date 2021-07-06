# frozen_string_literal: true

require 'rails_helper'

describe TaxaController do
  describe "forbidden actions" do
    context "when signed in as a user", as: :user do
      specify { expect(get(:new)).to have_http_status :forbidden }
      specify { expect(get(:edit, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:create)).to have_http_status :forbidden }
      specify { expect(put(:update, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "GET new", as: :editor do
    context "when rank is species" do
      let(:parent) { create :genus }
      let(:params) do
        {
          parent_id: parent.id,
          rank_to_create: Rank::SPECIES
        }
      end

      specify { expect(get(:new, params: params)).to render_template 'new' }

      specify do
        get :new, params: params

        taxon = assigns(:taxon)
        expect(taxon).to be_a Species
        expect(taxon.genus).to eq parent
      end
    end
  end

  describe "POST create", as: :editor do
    let(:authorship_reference) { create :any_reference }
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

    describe "general attributes not specific for a single rank (using a genus as a stand-in)" do
      let(:parent) { create :subfamily }
      let(:params_without_taxon) do
        {
          parent_id: parent.id,
          rank_to_create: Rank::GENUS,
          taxon_name_string: "Atta",
          protonym_name_string: "Atta"
        }
      end

      describe "most minimal amount of params" do
        it "creates a record" do
          params = params_without_taxon.merge(taxon: base_params)
          expect { post :create, params: params }.to change { Taxon.count }.by(1)
        end
      end

      describe "general taxon attributes" do
        let(:taxon_params) do
          base_params.deep_merge(
            unresolved_homonym: true
          )
        end

        specify do
          post :create, params: params_without_taxon.merge(taxon: taxon_params)

          taxon = Taxon.last

          expect(taxon.status).to eq taxon_params[:status]
          expect(taxon.unresolved_homonym).to eq taxon_params[:unresolved_homonym]
        end
      end

      describe "general protonym attributes" do
        let(:taxon_params) do
          base_params.deep_merge(
            protonym_attributes: {
              fossil: true,
              sic: true,
              notes_taxt: "notes taxt",
              authorship_attributes: {
                pages: "21 pp."
              }
            }
          )
        end

        it 'sets protonym_attributes' do
          post :create, params: params_without_taxon.merge(taxon: taxon_params)

          protonym = Taxon.last.protonym
          protonym_attributes = taxon_params[:protonym_attributes]

          expect(protonym.fossil).to eq protonym_attributes[:fossil]
          expect(protonym.sic).to eq protonym_attributes[:sic]

          expect(protonym.notes_taxt).to eq protonym_attributes[:notes_taxt]
        end

        it 'sets authorship_attributes' do
          post :create, params: params_without_taxon.merge(taxon: taxon_params)

          authorship = Taxon.last.protonym.authorship
          authorship_attributes = taxon_params[:protonym_attributes][:authorship_attributes]

          expect(authorship.pages).to eq authorship_attributes[:pages]
        end

        context 'when `protonym_id` is supplied' do
          let(:protonym) { create :protonym }

          it 'uses the ID and ignores the protonym attributes' do
            post :create, params: params_without_taxon.merge(taxon: taxon_params.merge(protonym_id: protonym.id))
            expect(Taxon.last.protonym.id).to eq protonym.id
          end
        end
      end

      describe "setting `current_taxon`" do
        let(:current_taxon) { create :genus }
        let(:taxon_params) do
          base_params.deep_merge(
            status: Status::SYNONYM,
            current_taxon_id: current_taxon.id
          )
        end

        specify do
          post :create, params: params_without_taxon.merge(taxon: taxon_params)
          expect(Taxon.last.current_taxon).to eq current_taxon
        end
      end
    end

    context 'with non-matching name type' do
      let(:parent) { create :subfamily }
      let(:params_without_taxon) do
        {
          parent_id: parent.id,
          rank_to_create: Rank::GENUS,
          taxon_name_string: "Attini",
          protonym_name_string: "Atta"
        }
      end

      it "does not create a record" do
        params = params_without_taxon.merge(taxon: base_params)
        expect { post :create, params: params }.to_not change { Taxon.count }

        taxon_assign = assigns(:taxon) # TODO: Hmm.
        expect(taxon_assign.errors.empty?).to eq false
        expect(taxon_assign.errors[:base]).to eq ["Rank (`Genus`) and name type (`TribeName`) must match."]
      end
    end

    context "when rank is genus" do
      let(:parent) { create :subfamily }
      let(:params_without_taxon) do
        {
          parent_id: parent.id,
          rank_to_create: Rank::GENUS,
          taxon_name_string: "Atta",
          protonym_name_string: "Atta"
        }
      end

      describe "genus-group taxon attributes" do
        let(:taxon_params) do
          base_params.deep_merge(
            incertae_sedis_in: Rank::FAMILY,
            collective_group_name: true,
            protonym_attributes: {
              fossil: true
            }
          )
        end

        it 'creates a genus record' do
          post :create, params: params_without_taxon.merge(taxon: taxon_params)

          taxon = Taxon.last

          expect(taxon).to be_a Genus
          expect(taxon.subfamily).to eq parent

          expect(taxon.incertae_sedis_in).to eq taxon_params[:incertae_sedis_in]
          expect(taxon.collective_group_name).to eq taxon_params[:collective_group_name]
        end
      end
    end

    context "when rank is species" do
      let(:parent) { create :genus }
      let(:params_without_taxon) do
        {
          parent_id: parent.id,
          rank_to_create: Rank::SPECIES,
          taxon_name_string: "Atta bapa",
          protonym_name_string: "Atta bapa"
        }
      end

      describe "species-group taxon attributes" do
        let(:taxon_params) do
          base_params.deep_merge(
            original_combination: true
          )
        end

        it 'creates a species record' do
          post :create, params: params_without_taxon.merge(taxon: taxon_params)

          taxon = Taxon.last

          expect(taxon).to be_a Species
          expect(taxon.genus).to eq parent

          expect(taxon.original_combination).to eq taxon_params[:original_combination]
        end
      end

      describe "species-group protonym attributes" do
        let(:taxon_params) do
          base_params.deep_merge(
            protonym_attributes: {
              locality: "San Francisco",
              forms: "w.",
              primary_type_information_taxt: "primary type information",
              secondary_type_information_taxt: "secondary type information",
              type_notes_taxt: "type notes"
            }
          )
        end

        it 'sets protonym_attributes' do
          post :create, params: params_without_taxon.merge(taxon: taxon_params)

          protonym = Taxon.last.protonym
          protonym_attributes = taxon_params[:protonym_attributes]

          expect(protonym.locality).to eq protonym_attributes[:locality]
          expect(protonym.forms).to eq protonym_attributes[:forms]

          expect(protonym.primary_type_information_taxt).to eq protonym_attributes[:primary_type_information_taxt]
          expect(protonym.secondary_type_information_taxt).to eq protonym_attributes[:secondary_type_information_taxt]
          expect(protonym.type_notes_taxt).to eq protonym_attributes[:type_notes_taxt]
        end
      end
    end
  end

  describe "PUT update", as: :editor do
    let!(:taxon) { create :subfamily }
    let!(:taxon_params) do
      {
        status:  Status::EXCLUDED_FROM_FORMICIDAE
      }
    end

    it 'updates the taxon' do
      put(:update, params: { id: taxon.id, taxon: taxon_params })

      taxon.reload
      expect(taxon.status).to eq taxon_params[:status]
    end

    it 'creates an activity' do
      expect { put(:update, params: { id: taxon.id, taxon: taxon_params, edit_summary: 'Fix status' }) }.
        to change { Activity.where(action: Activity::UPDATE, trackable: taxon).count }.by(1)

      activity = Activity.last
      expect(activity.edit_summary).to eq "Fix status"
    end
  end

  describe "DELETE destroy", as: :editor do
    let!(:taxon) { create :subfamily, :with_family }

    it 'deletes the taxon' do
      expect { delete(:destroy, params: { id: taxon.id }) }.to change { Taxon.count }.by(-1)
    end

    it 'creates an activity' do
      expect { delete(:destroy, params: { id: taxon.id }) }.
        to change { Activity.where(action: Activity::DESTROY, trackable: taxon).count }.by(1)
    end
  end
end
