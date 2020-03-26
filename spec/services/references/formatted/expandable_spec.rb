# frozen_string_literal: true

require 'rails_helper'

describe References::Formatted::Expandable do
  subject(:formatter) { described_class.new(reference) }

  describe '#call' do
    let(:author_name) { create :author_name, name: "Forel, A." }
    let(:reference) do
      create :article_reference, :with_doi, author_names: [author_name], citation_year: '1874',
        title: "*Atta* <i>and such</i>", series_volume_issue: '(1)', pagination: '3'
    end

    before do
      allow(reference).to receive(:routed_url).and_return 'example.com'
      allow(reference).to receive(:downloadable?).and_return true
    end

    specify { expect(formatter.call.html_safe?).to eq true }

    specify do
      expect(formatter.call).to eq <<~HTML.squish
        <span data-tooltip="true" data-allow-html="true" data-tooltip-class="foundation-tooltip" tabindex="2"
          title="<a href=&quot;/authors/#{author_name.author.id}&quot;>#{author_name.name}</a> 1874.
            <a href=&quot;/references/#{reference.id}&quot;><i>Atta</i> <i>and such</i>.</a>
            #{reference.journal.name} (1):3.
            <a class=&quot;external-link&quot; href=&quot;https://doi.org/#{reference.doi}&quot;>#{reference.doi}</a>
            <a class=&quot;pdf-link&quot; href=&quot;example.com&quot;>PDF</a>">Forel, 1874</span>
      HTML
    end
  end
end
