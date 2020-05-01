# frozen_string_literal: true

require 'rails_helper'

describe References::AutocompletesController do
  describe "GET show", :search, as: :visitor do
    context "when there are matches" do
      before do
        create :any_reference, author_string: 'E.O. Wilson'
        create :any_reference, author_string: 'Bolton'
        Sunspot.commit
      end

      it "autocompletes" do
        get :show, params: { reference_q: "wilson", format: :json }

        expect(json_response.size).to eq 1
        expect(json_response.first["author"]).to eq 'E.O. Wilson'
      end
    end

    context "when there are no matches" do
      it "returns an empty response" do
        get :show, params: { reference_q: "willy", format: :json }
        expect(json_response.size).to eq 0
      end
    end

    describe "author queries not wrapped in quotes" do
      context "when query contains non-English characters" do
        before do
          create :any_reference, author_string: 'Bert Hölldobler'
          Sunspot.commit
        end

        it "autocompletes" do
          get :show, params: { reference_q: "author:höll", format: :json }

          expect(json_response.size).to eq 1
          expect(json_response.first["author"]).to eq 'Bert Hölldobler'
        end
      end

      context "when query contains hyphens" do
        before do
          create :any_reference, author_string: 'M.S. Abdul-Rassoul'
          Sunspot.commit
        end

        it "autocompletes" do
          get :show, params: { reference_q: "author:abdul-ras", format: :json }

          expect(json_response.size).to eq 1
          expect(json_response.first["author"]).to eq 'M.S. Abdul-Rassoul'
        end
      end
    end

    describe "formatting autosuggest keywords" do
      let!(:reference) { create :any_reference, author_string: 'E.O. Wilson' }

      before do
        Sunspot.commit
      end

      it 'expands partially typed keyword values' do
        get :show, params: { reference_q: 'author:wil', format: :json }
        expect(json_response).to eq(
          [
            {
              'id' => reference.id,
              "author" => "E.O. Wilson",
              "search_query" => "author:'E.O. Wilson'",
              "title" => reference.title,
              "year" => reference.citation_year,
              "url" => "/references/#{reference.id}"
            }
          ]
        )
      end
    end
  end
end
