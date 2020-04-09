# frozen_string_literal: true

require 'rails_helper'

describe References::Formatted::Expanded do
  include TestLinksHelpers

  subject(:formatter) { described_class.new(reference) }

  describe '#call' do
    context 'when reference is an `ArticleReference`' do
      let(:author_name) { create :author_name, name: "Forel, A." }
      let(:reference) do
        create :article_reference, :with_doi, author_names: [author_name], citation_year: '1874',
          title: "*Atta* <i>and such</i>", series_volume_issue: '(1)', pagination: '3'
      end

      specify { expect(formatter.call.html_safe?).to eq true }

      specify do
        expect(formatter.call).to eq <<~HTML.squish
          #{author_link(author_name)} 1874. <a href="/references/#{reference.id}"><i>Atta</i>
          <i>and such</i>.</a> #{reference.journal.name} (1):3.
        HTML
      end
    end

    context 'when reference is a `BookReference`' do
      let(:author_name) { create :author_name, name: "Forel, A." }
      let(:reference) do
        create :book_reference, author_names: [author_name],
          citation_year: "1874", title: '*Ants* <i>and such</i>', pagination: "22 pp.",
          publisher: create(:publisher, name: 'Wiley', place: 'San Francisco')
      end

      specify { expect(formatter.call.html_safe?).to eq true }

      specify do
        expect(formatter.call).to eq <<~HTML.squish
          #{author_link(author_name)} 1874. <a href="/references/#{reference.id}"><i>Ants</i>
          <i>and such</i>.</a> San Francisco: Wiley, 22 pp.
        HTML
      end
    end

    context 'when reference is a `NestedReference`' do
      let(:nestee_author_name) { create :author_name, name: "Mayr, E." }
      let(:author_name) { create :author_name, name: "Forel, A." }
      let(:nestee_reference) do
        create :book_reference, author_names: [nestee_author_name],
          citation_year: '2010', title: '*Lasius* <i>and such</i>', pagination: '32 pp.',
          publisher: create(:publisher, name: 'Wiley', place: 'New York')
      end
      let(:reference) do
        create :nested_reference, nesting_reference: nestee_reference,
          author_names: [author_name], title: '*Atta* <i>and such</i>',
          citation_year: '1874', pagination: 'Pp. 32-45 in'
      end

      specify { expect(formatter.call.html_safe?).to eq true }

      specify do
        expect(formatter.call).to eq <<~HTML.squish
          #{author_link(author_name)} 1874. <a href="/references/#{reference.id}"><i>Atta</i> <i>and such</i>.</a>
          Pp. 32-45 in #{author_link(nestee_author_name)} 2010. <a href="/references/#{nestee_reference.id}"><i>Lasius</i>
          <i>and such</i>.</a> New York: Wiley, 32 pp.
        HTML
      end
    end

    context 'when reference is online early' do
      let(:reference) { create :any_reference, online_early: true }

      specify { expect(formatter.call).to include ' [online early]' }
    end
  end
end
