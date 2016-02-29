require 'spec_helper'

describe Api::V1::TaxaController do
  describe "getting data" do
    it "should get a single taxon entry" do
      # atta = create_genus 'Atta'
      # attacus = create_genus 'Attacus'
      # ratta = create_genus 'Ratta'
      # nylanderia = create_genus 'Nylanderia'
      species = create_species 'Atta minor maxus'
      # protonym_name = create_subspecies_name 'Eciton minor maxus'
      get(:show, {'id' => '4'}, nil)
      expect(response.status).to eq(200)
      parsed_species=JSON.parse(response.body)

      # "{"subfamily":{"id":1,"created_at":"2016-01-23T19:51:16.000Z","updated_at":"2016-01-23T19:51:16.000Z","fossil":false,"status":"valid","subfamily_id":null,"tribe_id":null,"genus_id":null,"homonym_replaced_by_id":null,"incertae_sedis_in":null,"species_id":null,"protonym_id":1,"type_taxt":null,"headline_notes_taxt":null,"subgenus_id":null,"hong":false,"name_id":5,"type_name_id":6,"genus_species_header_notes_taxt":null,"type_fossil":null,"name_cache":"Subfamily1","name_html_cache":"Subfamily1","unresolved_homonym":false,"current_valid_taxon_id":null,"ichnotaxon":null,"nomen_nudum":null,"family_id":null,"verbatim_type_locality":null,"biogeographic_region":null,"type_specimen_repository":null,"type_specimen_code":null,"type_specimen_url":null,"collision_merge_id":null,"auto_generated":false,"origin":null,"display":true}}"
      expect(response.body.to_s).to include("Atta")
      expect(parsed_species['species']['name_cache']).to eq("Atta minor maxus")

      # get(:show, {'id' => '12'}, nil)
      # expect(response.status).to eq(200)
      # parsed_species=JSON.parse(response.body)
      # expect(response.body.to_s).not_to include("<html>")
      #
      #
      # get :index, {:group_id => group_id, :use_route => :groups}.merge(@json_auth), nil
      # connections=JSON.parse(response.body)
      # expect(connections).to have(2).items
      # expect(response.body.to_s).to include("account_name_1")
      # expect(response.body.to_s).to include("account_name_2")
    end

  end
end
