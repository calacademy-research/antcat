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

    it "should search for a taxa" do
      species = create_species 'Atta minor maxus'
      get(:search, {'string' => 'maxus'}, nil)
      expect(response.status).to eq(200)
      expect(response.body.to_s).to include("maxus")

    end

    it "should report when there are no search matches" do
      species = create_species 'Atta minor maxus'
      get(:search, {'string' => 'maxuus'}, nil)
      expect(response.status).to eq(404)

    end

  end
end
