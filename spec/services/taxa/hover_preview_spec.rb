# frozen_string_literal: true

require 'rails_helper'

describe Taxa::HoverPreview do
  include TestLinksHelpers

  describe "#call" do
    let(:taxon) { create :genus }

    specify do
      nomen_synopsis =
        %(<b>Name:</b> #{taxon_link(taxon)}<br>) +
        %(<b>Author citation:</b> #{taxon.author_citation}<br>) +
        %(<b>Rank:</b> Genus<br>) +
        %(<b>Status:</b> #{taxon.decorate.expanded_status}<br>)

      authorship =
        taxon.authorship_reference.decorate.link_to_reference + ': ' +
        taxon.protonym.authorship_pages

      protonym_synopsis =
        %(<b>Protonym:</b> #{taxon.protonym.decorate.link_to_protonym}<br>) +
        %(<b>Authorship:</b> #{authorship})

      expect(described_class[taxon]).to include(nomen_synopsis)
      expect(described_class[taxon]).to include(authorship)
      expect(described_class[taxon]).to include(protonym_synopsis)

      expect(described_class[taxon]).to eq(nomen_synopsis + '<br>' + protonym_synopsis)
    end
  end
end
