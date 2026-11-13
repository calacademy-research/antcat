# frozen_string_literal: true

# Developer pages that show the pickers and the styles of the site. No route points at this controller
# (config/routes.rb, 2026-11-13), so the pages cannot be opened: a candidate for removal.
class DevsController < ApplicationController
  helper_method :show_picker?

  def show
  end

  def pickers
    @_visible_pickers = params[:p]&.split(',')
  end

  def styles
  end

  private

    def show_picker? picker_name
      return true if @_visible_pickers.blank?
      picker_name.in?(@_visible_pickers)
    end
end
