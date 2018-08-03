require 'spec_helper'

describe Api::V1::AuthorsController do
  let!(:author) { create :author }

  describe "GET index" do
    let!(:another_author) { create :author }

    before { get :index }

    it "gets all author primary keys" do
      expect(response.body.to_s).to include author.id.to_s
      expect(response.body.to_s).to include another_author.id.to_s
      authors = JSON.parse response.body
      expect(authors.count).to eq 2
    end

    it 'returns HTTP 200' do
      expect(response).to have_http_status :ok
    end
  end

  describe "GET show" do
    before { get :show, params: { id: author.id } }

    it "fetches an author primary key" do
      expect(response.body.to_s).to include author.id.to_s
    end

    it 'returns HTTP 200' do
      expect(response).to have_http_status :ok
    end
  end
end
