# frozen_string_literal: true

# The page of notes on a name ("Notes on this name"): one per protonym, in Markdown.
#
# Routes: GET /protonyms/:protonym_id/notes (anyone); GET /protonyms/:protonym_id/notes/new (helpers); POST
# /protonyms/:protonym_id/notes (helpers); GET /protonyms/:protonym_id/notes/edit (helpers); PATCH
# /protonyms/:protonym_id/notes (helpers); PUT /protonyms/:protonym_id/notes (helpers); DELETE
# /protonyms/:protonym_id/notes (editors). Purpose, rights and tests of each: docs/catalog/routes.tsv.
module Protonyms
  class NotesController < ApplicationController
    before_action :ensure_unconfirmed_user_is_not_over_edit_limit, except: [:show]
    before_action :ensure_user_is_at_least_helper, except: [:show]
    before_action :ensure_user_is_editor, only: [:destroy]

    def show
      @protonym = find_protonym
      @notes_page = find_notes_page
    end

    def new
      @protonym = find_protonym
      return redirect_to edit_protonym_notes_path(@protonym) if @protonym.notes_page

      @notes_page = @protonym.build_notes_page
    end

    def create
      @protonym = find_protonym
      return redirect_to edit_protonym_notes_path(@protonym) if @protonym.notes_page

      @notes_page = @protonym.build_notes_page(notes_page_params)

      if @notes_page.save
        @notes_page.create_activity Activity::CREATE, current_user, edit_summary: params[:edit_summary]
        redirect_to protonym_notes_path(@protonym), notice: "Successfully created the notes on this name."
      else
        render :new, status: :unprocessable_content
      end
    rescue ActiveRecord::RecordNotUnique # Two people (or a double click) added the notes at the same moment.
      redirect_to edit_protonym_notes_path(@protonym), alert: "This name already has notes; they are shown here to edit."
    end

    def edit
      @protonym = find_protonym
      @notes_page = find_notes_page
    end

    def update
      @protonym = find_protonym
      @notes_page = find_notes_page

      if @notes_page.update(notes_page_params)
        @notes_page.create_activity Activity::UPDATE, current_user, edit_summary: params[:edit_summary]
        redirect_to protonym_notes_path(@protonym), notice: "Successfully updated the notes on this name."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @protonym = find_protonym
      notes_page = find_notes_page

      notes_page.destroy!
      notes_page.create_activity Activity::DESTROY, current_user

      redirect_to protonym_path(@protonym), notice: "The notes on this name were successfully deleted."
    end

    private

      def find_protonym
        Protonym.find(params.expect(:protonym_id))
      end

      def find_notes_page
        @protonym.notes_page || raise(ActiveRecord::RecordNotFound, "Protonym #{@protonym.id} has no page of notes")
      end

      def notes_page_params
        params.expect(notes_page: [:content])
      end
  end
end
