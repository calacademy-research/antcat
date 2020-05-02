# frozen_string_literal: true

module References
  class WhatLinksHeresController < ApplicationController
    def show
      @reference = find_reference
      @what_links_here_items = References::WhatLinksHere.new(@reference).all.paginate(page: params[:page])
    end

    private

      def find_reference
        Reference.find(params[:reference_id])
      end
  end
end
