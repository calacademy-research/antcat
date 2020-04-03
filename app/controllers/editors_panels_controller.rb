# frozen_string_literal: true

class EditorsPanelsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: :invite_users

  def index
    @editors_panel_presenter = EditorsPanelPresenter.new(current_user)
  end

  def invite_users
  end
end
