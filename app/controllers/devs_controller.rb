# frozen_string_literal: true

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
