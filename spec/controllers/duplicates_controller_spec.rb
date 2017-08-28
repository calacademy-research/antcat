# TODO perhaps this broke after setting `include_root_in_json` to true?
# See `config/initializers/wrap_parameters.rb` and
# http://api.rubyonrails.org/classes/ActiveModel/Serializers/JSON.html

require 'spec_helper'

describe DuplicatesController do
  before do
    @user = create :user
    @species_epithet = "species a"
    @genus_a = create_genus "GA"
    @species_a = create_species @species_epithet,
      genus: @genus_a,
      status: Status['original combination'].to_s
  end

  describe "find a duplicate case" do
    it "Should find a secondary_junior_homonym match for same name", pending: true do
      pending "Known to be broken - update to reflect current duplicates controller functinality"

      genus_b = create_genus "GB"
      species_b = create_species @species_epithet,
        genus: genus_b,
        status: Status['valid'].to_s
      sign_in @user

      get :show, parent_id: @genus_a.id,
        previous_combination_id: species_b.id,
        rank_to_create: 'species'

      expect(response).to have_http_status :ok
      taxa = JSON.parse response.body
      expect(taxa.size).to eq 1
      expect(taxa[0]['species']['name_cache']).to eq @species_epithet
      expect(taxa[0]['species']['duplicate_type']).to eq 'secondary_junior_homonym'
    end

    it "Should find a return_to_original match for same protonym", pending: true do
      pending "Known to be broken - update to reflect current duplicates controller functinality"

      genus_b = create_genus "GB"
      species_b = create_species @species_epithet,
        genus: genus_b,
        status: Status['valid'].to_s,
        protonym_id: @species_a.id
      sign_in @user

      get :show, parent_id: @genus_a.id,
        previous_combination_id: species_b.id,
        rank_to_create: 'species'

      expect(response).to have_http_status :ok
      taxa = JSON.parse response.body
      expect(taxa.size).to eq 1
      expect(taxa[0]['species']['name_cache']).to eq @species_epithet
      expect(taxa[0]['species']['duplicate_type']).to eq 'return_to_original'
    end

    it "Should find no matches for same protonym distinct epithet", pending: true do
      pending "Known to be broken - update to reflect current duplicates controller functinality"

      genus_b = create_genus "GB"
      species_b = create_species @species_epithet + "boo",
        genus: genus_b,
        status: Status['valid'].to_s,
        protonym_id: @species_a.id
      sign_in @user

      get :show, parent_id: @genus_a.id,
        previous_combination_id: species_b.id,
        rank_to_create: 'species'

      expect(response).to have_http_status 204
    end
  end
end
