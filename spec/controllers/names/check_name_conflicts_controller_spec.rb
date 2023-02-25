# frozen_string_literal: true

require 'rails_helper'

describe Names::CheckNameConflictsController do
  describe 'GET show', as: :visitor do
    let!(:protonym) { create :protonym, :family_group_subfamily_name, protonym_name_string: 'Antcatinae' }
    let!(:taxon) { create :family, name_string: 'Antcatidae', protonym: protonym }

    specify do
      get :show, params: { qq: 'Antc' }

      expect(json_response).to match_array(
        [
          {
            "id" => taxon.name.id,
            "name" => "Antcatidae",
            "name_html" => "Antcatidae",
            "protonym_id" => nil,
            "taxon_id" => taxon.id
          },
          {
            "id" => protonym.name.id,
            "name" => "Antcatinae",
            "name_html" => "Antcatinae",
            "protonym_id" => protonym.id,
            "taxon_id" => nil
          }
        ]
      )
    end
  end
end
