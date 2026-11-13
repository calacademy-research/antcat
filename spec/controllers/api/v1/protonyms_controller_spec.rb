# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::ProtonymsController, as: :visitor do
  describe "GET index" do
    specify do
      protonym = create :protonym
      get :index
      expect(json_response).to eq([protonym.as_json(only: described_class::ATTRIBUTES, root: true)])
    end

    specify { expect(get(:index)).to have_http_status :ok }
  end

  describe "GET show" do
    let(:protonym) { create :protonym }

    context 'with genus-group protonym' do
      let!(:protonym) do
        create :protonym, :species_group, :with_type_name, :with_all_taxts
      end

      specify do
        get :show, params: { id: protonym.id }
        expect(json_response).to eq(
          {
            "protonym" => {
              "id" => protonym.id,
              "name_id" => protonym.name.id,
              "authorship_id" => protonym.authorship.id,
              "sic" => protonym.sic,
              "fossil" => protonym.fossil,
              "ichnotaxon" => protonym.ichnotaxon,
              "bioregion" => nil,
              "locality" => nil,
              "forms" => nil,
              "gender_agreement_type" => nil,
              "masculine_epithet" => nil,
              "feminine_epithet" => nil,
              "neuter_epithet" => nil,
              "part_of_speech_basis" => nil,
              "spelling_basis" => nil,
              "interpretation_status" => nil,
              "grammar_and_spelling_wiki_page_id" => nil,
              "etymology_taxt" => protonym.etymology_taxt,
              "primary_type_information_taxt" => protonym.primary_type_information_taxt,
              "secondary_type_information_taxt" => protonym.secondary_type_information_taxt,
              "type_notes_taxt" => protonym.type_notes_taxt,
              "notes_taxt" => protonym.notes_taxt,

              "created_at" => protonym.created_at.as_json,
              "updated_at" => protonym.updated_at.as_json
            }
          }
        )
      end
    end

    context 'with species-group protonym' do
      let!(:protonym) do
        create :protonym, :species_group, bioregion: Protonym::NEARCTIC_REGION,
          locality: "USA", forms: 'q.', gender_agreement_type: Protonym::ADJECTIVE,
          masculine_epithet: "crassispinus", feminine_epithet: "crassispina", neuter_epithet: "crassispinum",
          part_of_speech_basis: 'original_usage', spelling_basis: 'gender_agreement',
          interpretation_status: 'disputed', notes_taxt: "Spelling: an alternative reading is a noun phrase."
      end

      specify do
        get :show, params: { id: protonym.id }
        expect(json_response).to eq(
          {
            "protonym" => {
              "id" => protonym.id,
              "name_id" => protonym.name.id,
              "authorship_id" => protonym.authorship.id,
              "sic" => protonym.sic,
              "fossil" => protonym.fossil,
              "ichnotaxon" => protonym.ichnotaxon,
              "bioregion" => Protonym::NEARCTIC_REGION,
              "locality" => 'USA',
              "forms" => protonym.forms,
              "gender_agreement_type" => Protonym::ADJECTIVE,
              "masculine_epithet" => "crassispinus",
              "feminine_epithet" => "crassispina",
              "neuter_epithet" => "crassispinum",
              "part_of_speech_basis" => 'original_usage',
              "spelling_basis" => 'gender_agreement',
              "interpretation_status" => 'disputed',
              "grammar_and_spelling_wiki_page_id" => nil,
              "etymology_taxt" => nil,
              "primary_type_information_taxt" => protonym.primary_type_information_taxt,
              "secondary_type_information_taxt" => protonym.secondary_type_information_taxt,
              "type_notes_taxt" => protonym.type_notes_taxt,
              "notes_taxt" => protonym.notes_taxt,

              "created_at" => protonym.created_at.as_json,
              "updated_at" => protonym.updated_at.as_json
            }
          }
        )
      end
    end

    specify { expect(get(:show, params: { id: protonym.id })).to have_http_status :ok }
  end
end
