# frozen_string_literal: true

module Catalog
  class ToggleDisplaysController < ApplicationController
    VALID_ONLY = 'valid_only'
    VALID_AND_INVALID = 'valid_and_invalid'

    def update
      session[:show_invalid] = case params[:show]
                               when VALID_ONLY        then false
                               when VALID_AND_INVALID then true
                               else raise 'unknown show param'
                               end
      redirect_back fallback_location: root_path
    end
  end
end
