# frozen_string_literal: true

require 'rails_helper'

describe NotesPagesController do
  describe "GET index", as: :visitor do
    render_views

    it "lists the names that have a page of notes, with a link to each page" do
      protonym = create :protonym
      create :notes_page, protonym: protonym, content: "## Etymological notes\n\nText."

      get :index

      expect(response).to render_template :index
      expect(response.body).to include protonym.name.name
      expect(response.body).to include protonym_notes_path(protonym)
      expect(response.body).to include "Etymological notes"
    end

    it "renders without any page of notes" do
      get :index
      expect(response.body).to include "There are no names with notes yet."
    end
  end
end
