# frozen_string_literal: true

require 'rails_helper'

describe Catalog::HoverPreviewsController do
  include TestLinksHelpers

  describe "GET show", as: :visitor do
    let(:taxon) { create :genus }

    specify do
      get(:show, params: { id: taxon.id })

      preview = json_response['preview']

      expected = <<~HTML
        <b>Name:</b> #{taxon_link(taxon)}<br>
        <b>Author citation:</b> #{taxon.author_citation}<br>
        <b>Rank:</b> Genus<br>
        <b>Status:</b> #{taxon.decorate.expanded_status}<br>
        <br>

        <b>Protonym:</b> #{taxon.protonym.decorate.link_to_protonym}<br>
        <b>Authorship:</b> #{taxon_authorship_link(taxon)}: #{taxon.protonym.authorship_pages}
      HTML

      expected.each_line do |line|
        expect(preview.squish).to include line.squish
      end
      expect(preview.squish).to eq expected.squish
    end
  end
end
