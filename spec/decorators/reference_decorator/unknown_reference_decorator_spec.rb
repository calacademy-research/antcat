require 'spec_helper'

describe UnknownReferenceDecorator do
  let(:author_name) { create :author_name, name: "Forel, A." }
  let(:reference) do
    create :unknown_reference, author_names: [author_name], citation_year: "1874",
      title: "Les fourmis de la Suisse.", citation: '*Ants* <i>and such</i>'
  end

  describe "#plain_text" do
    specify { expect(reference.decorate.plain_text).to be_html_safe }

    specify do
      expect(reference.decorate.plain_text).to eq 'Forel, A. 1874. Les fourmis de la Suisse. Ants and such.'
    end

    context "with unsafe characters" do
      it "escapes them" do
        reference = create :unknown_reference, citation: '<span>Tapinoma</span>'
        expect(reference.decorate.plain_text).to include "&lt;span&gt;Tapinoma&lt;/span&gt;"
      end
    end
  end

  describe "#expanded_reference" do
    specify { expect(reference.decorate.expanded_reference).to be_html_safe }

    specify do
      expect(reference.decorate.expanded_reference).to eq <<~HTML.squish
        Forel, A. 1874. <a href="/references/#{reference.id}">Les fourmis de la Suisse.</a> <i>Ants</i> <i>and such</i>.
      HTML
    end
  end
end
