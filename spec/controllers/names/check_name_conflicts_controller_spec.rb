require 'spec_helper'

describe Names::CheckNameConflictsController do
  describe 'GET show' do
    let!(:protonym) { create :protonym, name: create(:subfamily_name, name: 'Antcatinae') }
    let!(:taxon) { create :family, name_string: 'Antcatidae', protonym: protonym }

    specify do
      get :show, params: { qq: 'Antc' }

      expect(json_response).to eq(
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
