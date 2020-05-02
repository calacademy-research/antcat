# frozen_string_literal: true

module Protonyms
  class WhatLinksHeresController < ApplicationController
    def show
      @protonym = find_protonym
      @what_links_here_items = Protonyms::WhatLinksHere.new(@protonym).all.paginate(page: params[:page])
    end

    private

      def find_protonym
        Protonym.find(params[:protonym_id])
      end
  end
end
