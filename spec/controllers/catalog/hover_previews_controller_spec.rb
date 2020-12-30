# frozen_string_literal: true

require 'rails_helper'

describe Catalog::HoverPreviewsController do
  include TestLinksHelpers

  describe "GET show", as: :visitor do
    let(:taxon) { create :genus }

    specify do
      get(:show, params: { id: taxon.id })

      preview = json_response['preview']

      expect(preview.squish).to eq <<~HTML.squish
        <strong>Taxon:</strong> #{taxon_link(taxon)} #{taxon.author_citation}
        <br>

        <strong>Rank:</strong> Genus
        <br>

        <strong>Status:</strong> #{taxon.decorate.expanded_status}
        <br>
        <br>

        <strong>Protonym:</strong> #{protonym_link(taxon.protonym)}
        <br>

        <strong>Authorship:</strong> #{taxon_authorship_link(taxon)}: #{taxon.protonym.authorship_pages}
      HTML
    end
  end
end
