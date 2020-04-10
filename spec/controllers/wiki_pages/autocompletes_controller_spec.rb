# frozen_string_literal: true

require 'rails_helper'

describe WikiPages::AutocompletesController do
  describe "GET show", as: :visitor do
    let!(:help_wiki_page) { create :wiki_page, title: 'Help' }
    let!(:news_wiki_page) { create :wiki_page, title: 'News' }

    it "calls `Autocomplete::AutocompleteWikiPages`" do
      expect(Autocomplete::AutocompleteWikiPages).to receive(:new).with('q').and_call_original
      get :show, params: { q: 'q', format: :json }
    end

    specify do
      get :show, params: { q: 'hel', format: :json }
      expect(json_response).to eq [{ 'id' => help_wiki_page.id, 'title' => help_wiki_page.title }]
    end

    context 'when a wiki page ID is given' do
      specify do
        get :show, params: { q: news_wiki_page.id.to_s, format: :json }
        expect(json_response).to eq [{ 'id' => news_wiki_page.id, 'title' => news_wiki_page.title }]
      end
    end
  end
end
