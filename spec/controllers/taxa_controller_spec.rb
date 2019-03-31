require 'spec_helper'

describe TaxaController do
  describe "forbidden actions" do
    context "when signed in as a user" do
      before { sign_in create(:user) }

      specify { expect(get(:new)).to have_http_status :forbidden }
      specify { expect(get(:edit, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:create)).to have_http_status :forbidden }
      specify { expect(post(:update, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end
  end

  # rubocop:disable RSpec/MultipleExpectations
  describe "POST create" do
    before do
      sign_in create(:user, :editor)
    end

    let(:authorship_reference) { create :article_reference }
    let(:name) { create :genus_name }
    let(:protonym_name) { create :genus_name }

    let(:base_params) do
      HashWithIndifferentAccess.new(
        status: Status::VALID,
        name_attributes: {
          id: name.id
        },
        protonym_attributes: {
          name_attributes: {
            id: protonym_name.id
          },
          authorship_attributes: {
            reference_id: authorship_reference.id
          }
        }
      )
    end

    context 'with valid params' do
      context "when rank is genus" do
        let(:parent) { create :subfamily }
        let(:genus_params) do
          { parent_id: parent.id, rank_to_create: "genus" }
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
          let(:homonym_replaced_by) { create :genus }
          let(:type_taxon) { create :species }
          let(:taxon_params) do
            base_params.deep_merge(
              homonym_replaced_by_id: homonym_replaced_by.id,
              incertae_sedis_in: "family",
              fossil: true,
              nomen_nudum: true,
              unresolved_homonym: true,
              ichnotaxon: true,
              hong: true,
              headline_notes_taxt: "headline notes taxt",
              type_taxt: "type taxt",
              biogeographic_region: Taxon::BIOGEOGRAPHIC_REGIONS.first,
              primary_type_information: "primary type information",
              secondary_type_information: "secondary type information",
              type_notes: "type notes",
              type_taxon_id: type_taxon.id
            )
          end

          specify do
            post :create, params: genus_params.merge(taxon: taxon_params)

            taxon = Taxon.last

            expect(taxon.status).to eq taxon_params[:status]
            expect(taxon.homonym_replaced_by).to eq homonym_replaced_by
            expect(taxon.incertae_sedis_in).to eq taxon_params[:incertae_sedis_in]
            expect(taxon.fossil).to eq taxon_params[:fossil]
            expect(taxon.nomen_nudum).to eq taxon_params[:nomen_nudum]
            expect(taxon.unresolved_homonym).to eq taxon_params[:unresolved_homonym]
            expect(taxon.ichnotaxon).to eq taxon_params[:ichnotaxon]
            expect(taxon.hong).to eq taxon_params[:hong]
            expect(taxon.headline_notes_taxt).to eq taxon_params[:headline_notes_taxt]
            expect(taxon.type_taxt).to eq taxon_params[:type_taxt]
            expect(taxon.biogeographic_region).to eq taxon_params[:biogeographic_region]
            expect(taxon.primary_type_information).to eq taxon_params[:primary_type_information]
            expect(taxon.secondary_type_information).to eq taxon_params[:secondary_type_information]
            expect(taxon.type_notes).to eq taxon_params[:type_notes]
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
                authorship_attributes: {
                  pages: "21 pp.",
                  forms: "w.",
                  notes_taxt: "notes taxt"
                }
              }
            )
          end

          specify do
            post :create, params: genus_params.merge(taxon: taxon_params)

            protonym = Taxon.last.protonym
            protonym_attributes = taxon_params[:protonym_attributes]

            expect(protonym.fossil).to eq protonym_attributes[:fossil]
            expect(protonym.sic).to eq protonym_attributes[:sic]
            expect(protonym.locality).to eq protonym_attributes[:locality]
          end

          specify do
            post :create, params: genus_params.merge(taxon: taxon_params)

            authorship = Taxon.last.protonym.authorship
            authorship_attributes = taxon_params[:protonym_attributes][:authorship_attributes]

            expect(authorship.pages).to eq authorship_attributes[:pages]
            expect(authorship.forms).to eq authorship_attributes[:forms]
            expect(authorship.notes_taxt).to eq authorship_attributes[:notes_taxt]
          end

          context 'when `protonym_id` is supplied' do
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
    end
    # rubocop:enable RSpec/MultipleExpectations
  end
end
