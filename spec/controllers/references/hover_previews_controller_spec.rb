# frozen_string_literal: true

require 'rails_helper'

describe References::HoverPreviewsController do
  describe "GET show", as: :visitor do
    let!(:reference) { create :any_reference, :with_document }

    specify do
      get(:show, params: { reference_id: reference.id })

      preview = json_response['preview']

      expect(preview.squish).to eq <<~HTML.squish
        <strong>Reference:</strong> #{reference.key_with_suffixed_year}
        <br>

        <strong>Pages:</strong> #{reference.pagination}
        <br>
        <br>

        <div class='small-text'>
          #{reference.decorate.expanded_reference}
          #{reference.decorate.format_document_links}
        </div>
      HTML
    end
  end
end
