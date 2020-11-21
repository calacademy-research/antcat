# frozen_string_literal: true

require 'rails_helper'

describe TooltipHelper do
  describe "#db_tooltip_icon" do
    context 'when tooltip exists' do
      context 'with unsafe tags' do
        before do
          create :tooltip, key: 'xss', scope: 'injection', text: '<script>xss</script>'
        end

        it "sanitizes them" do
          results = helper.db_tooltip_icon('xss', scope: 'injection')
          expect(results).to_not include '<script>xss</script>'
          expect(results).to_not include '&lt;script&gt;xss&lt;/script&gt;'
          expect(results).to include '"xss"'
        end
      end
    end
  end

  describe "#db_wiki_page_icon" do
    context 'when wiki page does not exists' do
      specify do
        expect(helper.db_wiki_page_icon('pizza')).to eq <<~HTML.squish
          <a href="/wiki_pages"><span tooltip2="Related wiki page: Error:
          Could not find wiki page 'pizza'" class="tooltip2"><i
          class="antcat_icon wiki-page-icon"></i></span></a>
        HTML
      end
    end

    context 'when wiki page exists' do
      it 'links the wiki page' do
        wiki_page = create :wiki_page, :forms

        expect(helper.db_wiki_page_icon(wiki_page.permanent_identifier)).to eq <<~HTML.squish
          <a href="/wiki_pages/#{wiki_page.id}"><span tooltip2="Related wiki page: #{wiki_page.title}"
          class="tooltip2"><i class="antcat_icon wiki-page-icon"></i></span></a>
        HTML
      end

      context 'with unsafe tags' do
        let!(:wiki_page) { create :wiki_page, :forms, title: '<script>xss</script>' }

        it "sanitizes them" do
          results = helper.db_wiki_page_icon(wiki_page.permanent_identifier)
          expect(results).to_not include '<script>xss</script>'
          expect(results).to_not include '&lt;script&gt;xss&lt;/script&gt;'
          expect(results).to include 'xss'
        end
      end
    end
  end
end
