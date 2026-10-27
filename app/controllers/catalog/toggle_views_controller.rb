# frozen_string_literal: true

module Catalog
  class ToggleViewsController < ApplicationController
    VALID_ONLY = 'valid_only'
    VALID_AND_INVALID = 'valid_and_invalid'

    def update
      case params[:show]
      when VALID_ONLY        then session[:show_invalid] = false
      when VALID_AND_INVALID then session[:show_invalid] = true
      else
        head :bad_request
        return
      end

      redirect_back_or_to(root_path)
    end
  end
end
