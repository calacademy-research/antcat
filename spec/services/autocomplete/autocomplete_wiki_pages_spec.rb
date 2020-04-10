# frozen_string_literal: true

require 'rails_helper'

describe Autocomplete::AutocompleteWikiPages do
  describe "#call" do
    let!(:help_wiki_page) { create :wiki_page, title: 'Help' }
    let!(:news_wiki_page) { create :wiki_page, title: 'News' }

    specify do
      expect(described_class['Hel']).to eq [help_wiki_page]
    end

    context 'when a wiki page ID is given' do
      specify do
        expect(described_class[news_wiki_page.id.to_s]).to eq [news_wiki_page]
      end
    end
  end
end
