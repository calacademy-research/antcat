# frozen_string_literal: true

# The editor's panel: links to tools and recent changes.
#
# Routes: GET /panel (signed in); GET /panel/invite_users (signed in). Purpose, rights and tests of each:
# docs/catalog/routes.tsv.
class EditorsPanelsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: :invite_users

  def show
    @editors_panel_presenter = EditorsPanelPresenter.new(current_user)
  end

  def invite_users
  end
end
