# frozen_string_literal: true

require 'rails_helper'

describe Markdowns::ParseAntCatTags do
  describe "#call" do
    context 'with unsafe tags' do
      it "does not sanitize them" do
        content = "<i>italics<i><i><script>xss</script></i>"
        expect(described_class[content.dup]).to eq content
      end
    end

    describe 'tag: `GITHUB_TAG_REGEX`' do
      it "formats GitHub links" do
        expect(described_class["%github5"]).
          to eq %(<a href="https://github.com/calacademy-research/antcat/issues/5">GitHub #5</a>)
      end
    end

    describe 'tag: `USER_TAG_REGEX`' do
      let(:user) { create :user }

      it "formats user links" do
        expect(described_class["@user#{user.id}"]).
          to eq %(<a class="font-bold" href="/users/#{user.id}">@#{user.name}</a>)
      end
    end

    describe 'tag: `DBSCRIPT_TAG_REGEX`' do
      context 'when database script exists' do
        specify do
          expect(described_class["%dbscript:OrphanedProtonyms"].strip).to eq <<~HTML.squish
            <a href="/database_scripts/orphaned_protonyms">Orphaned protonyms</a>
            <span class="label-white rounded-badge">protonyms</span>
            <span class="label-warning rounded-badge">slow-render</span>
          HTML
        end
      end

      context 'when database script does not exist' do
        specify do
          expect(described_class["%dbscript:BestPizzas"].strip).to eq <<~HTML.squish
            <a href="/database_scripts/best_pizzas">Error: Could not find database script
            with class name &#39;BestPizzas&#39;</a>
          HTML
        end
      end
    end

    describe 'tag: `WIKI_TAG_REGEX`' do
      let!(:wiki_page) { create :wiki_page }

      specify do
        expect(described_class["%wiki#{wiki_page.id}"]).
          to eq %(<a href="/wiki/#{wiki_page.id}">#{wiki_page.title}</a>)
      end
    end
  end
end
