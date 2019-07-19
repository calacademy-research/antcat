require "spec_helper"

describe Autocomplete::AutocompleteWikiPages do
  describe "#call" do
    let!(:help_wiki_page) { create :wiki_page, title: 'Help' }
    let!(:news_wiki_page) { create :wiki_page, title: 'News' }

    specify do
      expect(described_class['Hel']).to eq [{ id: help_wiki_page.id, title: help_wiki_page.title }]
    end

    context 'when a wiki page ID is given' do
      specify do
        expect(described_class[news_wiki_page.id.to_s]).to eq [{ id: news_wiki_page.id, title: news_wiki_page.title }]
      end
    end
  end
end
