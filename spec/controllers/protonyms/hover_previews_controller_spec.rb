# frozen_string_literal: true

require 'rails_helper'

describe Protonyms::HoverPreviewsController do
  include TestLinksHelpers

  describe "GET show", as: :visitor do
    let!(:protonym) { create :protonym }

    specify do
      get(:show, params: { protonym_id: protonym.id })

      preview = json_response['preview']

      expect(preview.squish).to eq <<~HTML.squish
        <div class='div'>
          <strong>Protonym:</strong>
          #{protonym_link(protonym)}
        </div>
        <div class='margin-bottom'>
          <strong>Authorship:</strong>
          #{reference_link(protonym.authorship_reference)}: #{protonym.authorship_pages}
        </div>
      HTML
    end
  end
end
