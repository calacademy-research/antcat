require 'rails_helper'

describe BookReferenceDecorator do
  include TestLinksHelpers

  let(:author_name) { create :author_name, name: "Forel, A." }
  let(:reference) do
    create :book_reference, author_names: [author_name],
      citation_year: "1874", title: '*Ants* <i>and such</i>', pagination: "22 pp."
  end

  describe "#plain_text" do
    specify { expect(reference.decorate.plain_text).to be_html_safe }

    specify do
      expect(reference.decorate.plain_text).
        to eq 'Forel, A. 1874. Ants and such. San Francisco: Wiley, 22 pp.'
    end

    context 'with unsafe tags' do
      let!(:reference) do
        publisher = create :publisher, name: '<script>xss</script>', place_name: '<script>xss</script>'
        create :book_reference, publisher: publisher, pagination: '<script>xss</script>'
      end

      it "sanitizes them" do
        results = reference.decorate.plain_text
        expect(results).to_not include '<script>xss</script>'
        expect(results).to_not include '&lt;script&gt;xss&lt;/script&gt;'
        expect(results).to include 'xss'
      end
    end
  end

  describe "#expanded_reference" do
    specify { expect(reference.decorate.expanded_reference).to be_html_safe }

    specify do
      expect(reference.decorate.expanded_reference).to eq <<~HTML.squish
        #{author_link(author_name)} 1874. <a href="/references/#{reference.id}"><i>Ants</i>
        <i>and such</i>.</a> San Francisco: Wiley, 22 pp.
      HTML
    end
  end
end
