# frozen_string_literal: true

require 'rails_helper'

describe ProtonymDecorator do
  include TestLinksHelpers

  subject(:decorated) { protonym.decorate }

  describe "#link_to_protonym" do
    let(:protonym) { create :protonym }

    specify do
      expect(decorated.link_to_protonym).to eq <<~HTML.squish
        <a data-controller="hover-preview"
        data-hover-preview-url-value="/protonyms/#{protonym.id}/hover_preview.json"
        class="protonym"
        href="/protonyms/#{protonym.id}">#{protonym.name.name_html}</a>
      HTML
    end
  end

  describe "#link_to_protonym_with_author_citation" do
    let(:protonym) { create :protonym }

    specify do
      expect(decorated.link_to_protonym_with_author_citation).to eq <<~HTML.squish
        #{decorated.link_to_protonym} #{protonym.author_citation}
      HTML
    end
  end

  describe "#link_to_protonym_with_linked_author_citation" do
    let(:protonym) { create :protonym }

    specify do
      expect(decorated.link_to_protonym_with_linked_author_citation).to eq <<~HTML.squish
        #{decorated.link_to_protonym}
        <span class="discreet-author-citation">#{reference_link(protonym.authorship_reference)}</span>
      HTML
    end
  end

  describe "#format_locality" do
    context 'when `locality` contains parentheses' do
      context 'when locality contains words in parentheses' do
        let(:protonym) { build_stubbed :protonym, locality: 'Indonesia (Timor)' }

        it 'does not capitalize words wrapped in parentheses' do
          expect(decorated.format_locality).to eq "INDONESIA (Timor)"
        end
      end

      context 'when locality contains non-ASCII characters' do
        let(:protonym) { build_stubbed :protonym, locality: 'São Tomé & Príncipe (São Tomé I.)' }

        it 'capitalizes properly' do
          expect(decorated.format_locality).to eq "SÃO TOMÉ & PRÍNCIPE (São Tomé I.)"
        end
      end
    end
  end

  describe "#format_pages_and_forms" do
    context 'when protonym has `forms`' do
      let(:protonym) { build_stubbed :protonym, forms: 'w.' }

      specify do
        expect(decorated.format_pages_and_forms).to eq "#{protonym.authorship.pages} (#{protonym.forms})"
      end
    end
  end
end
