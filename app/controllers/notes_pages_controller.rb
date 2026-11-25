# frozen_string_literal: true

# "Names with notes": the list of the names that have a page of notes ("Notes on this name"), one of the four
# pages of the "Policies and help" section. A reader comes here from a policy to see the names it was applied to.
#
# Routes: GET /notes_pages (anyone). Purpose, rights and tests: docs/catalog/routes.tsv.
class NotesPagesController < ApplicationController
  def index
    @notes_pages = NotesPage.includes(protonym: [:name, { authorship: :reference }]).
      sort_by { |notes_page| notes_page.protonym.name.name }
    @open_questions_wiki_page = WikiPage.find_by(permanent_identifier: WikiPage::OPEN_GRAMMAR_AND_SPELLING_QUESTIONS)
  end
end
