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

  describe "#format_etymology_derivation" do
    context 'without a derivation' do
      let(:protonym) { create :protonym }

      specify { expect(decorated.format_etymology_derivation).to eq nil }
    end

    context 'with italics' do
      let(:protonym) do
        create :protonym, etymology_derivation:
          "Toponym: Formed from Mexico with the Latin adjectival suffix <i>-ensis</i>, 'of Mexico'."
      end

      it 'keeps <i>' do
        expect(decorated.format_etymology_derivation).
          to eq "Toponym: Formed from Mexico with the Latin adjectival suffix <i>-ensis</i>, 'of Mexico'."
      end
    end

    # Values saved before the model refused other markup (or written around it) must still render safely.
    context 'with other markup stored' do
      let(:protonym) { create :protonym }

      before do
        protonym.update_columns(
          etymology_derivation: %(Latin <i class="x" onclick="alert(1)">crassus</i>, <b>thick</b> & <a href="http://x">spina</a>)
        )
      end

      it 'renders no markup but <i>, without attributes, and escapes the text' do
        expect(decorated.format_etymology_derivation).to eq 'Latin <i>crassus</i>, thick &amp; spina'
      end
    end

    context 'with a script stored' do
      let(:protonym) { create :protonym }

      before { protonym.update_columns(etymology_derivation: 'Latin <script>alert(2)</script>crassus') }

      # Whether the script's text is dropped or kept as plain text depends on the sanitizer version; either way no
      # script element is rendered.
      it 'renders no script element' do
        expect(decorated.format_etymology_derivation).not_to include '<script'
        expect(decorated.format_etymology_derivation).to include 'crassus'
      end
    end
  end

  describe "#format_etymology_source" do
    context 'when the etymology is from the original description' do
      let(:protonym) do
        create :protonym, etymology_taxt: 'Named after the collector.', etymology_source: 'original_description',
          etymology_pages: '69'
      end

      specify do
        expect(decorated.format_etymology_source).
          to eq "(original description, #{reference_link(protonym.authorship_reference)}: 69)"
      end
    end

    context 'when the etymology is from a later work' do
      let(:reference) { create :any_reference }
      let(:protonym) do
        create :protonym, etymology_taxt: 'From Latin crassus.', etymology_source: 'later_work',
          etymology_pages: '44', etymology_reference: reference
      end

      specify { expect(decorated.format_etymology_source).to eq "(later work, #{reference_link(reference)}: 44)" }
    end

    context 'when no source is recorded' do
      let(:protonym) { create :protonym }

      specify { expect(decorated.format_etymology_source).to eq nil }
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
