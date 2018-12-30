require 'spec_helper'

describe ArticleReferenceDecorator do
  let(:author_name) { create :author_name, name: "Forel, A." }
  let!(:reference) do
    create :article_reference, author_names: [author_name], citation_year: '1874',
      title: "*Atta* <i>and such</i>",
      series_volume_issue: '(1)', pagination: '3', doi: "10.10.1038/nphys1170"
  end

  describe "#plain_text" do
    specify { expect(reference.decorate.plain_text).to be_html_safe }

    specify do
      results = reference.decorate.plain_text
      expect(results).to be_html_safe
      expect(results).to eq "Forel, A. 1874. Atta and such. #{reference.journal.name} (1):3."
    end

    context "with unsafe characters" do
      let(:reference) {  create :article_reference, journal: create(:journal, name: '<script>') }

      it "escapes them" do
        expect(reference.decorate.plain_text).to include '&lt;script&gt;'
      end
    end
  end

  describe "#expanded_reference" do
    specify { expect(reference.decorate.expanded_reference).to be_html_safe }

    specify do
      expect(reference.decorate.expanded_reference).to eq <<~HTML.squish
        Forel, A. 1874. <i>Atta</i> <i>and such</i>. #{reference.journal.name} (1):3.
      HTML
    end
  end

  describe "#expandable_reference" do
    before do
      allow(reference).to receive(:url).and_return 'example.com'
      allow(reference).to receive(:downloadable?).and_return true
    end

    specify do
      expect(reference.decorate.expandable_reference).to eq <<~HTML.squish
        <span data-tooltip="true" data-allow-html="true" data-tooltip-class="foundation-tooltip" tabindex="2"
          title="Forel, A. 1874. <i>Atta</i> <i>and such</i>. #{reference.journal.name} (1):3.
            <a class=&quot;btn-normal btn-tiny&quot; href=&quot;/references/#{reference.id}&quot;>#{reference.id}</a>
            <a class=&quot;external-link&quot; href=&quot;https://doi.org/#{reference.doi}&quot;>#{reference.doi}</a>
            <a class=&quot;external-link&quot; href=&quot;example.com&quot;>PDF</a>">Forel, 1874</span>
      HTML
    end
  end
end
