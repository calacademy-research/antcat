# frozen_string_literal: true

require 'rails_helper'

describe NotesPages::HistoriesController do
  describe "GET show", as: :visitor do
    let!(:notes_page) { create :notes_page }

    specify { expect(get(:show, params: { notes_page_id: notes_page.id })).to render_template :show }

    it 'shows the history of notes that were deleted', :versioning do
      notes_page.update!(content: "## Type specimen notes\n\nEdited.")
      notes_page.destroy!

      expect(get(:show, params: { notes_page_id: notes_page.id })).to render_template :show
    end
  end
end
