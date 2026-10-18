# frozen_string_literal: true

module Protonyms
  class WhatLinksHeresController < ApplicationController
    def show
      @protonym = find_protonym
      items = Protonyms::WhatLinksHere.new(@protonym).all
      # Visitors do not see links that exist only inside hidden notes.
      items = WhatLinksHereVisibleItems[items, @protonym, :protonym] unless Current.signed_in
      @what_links_here_items = items.paginate(page: params[:page])
    end

    private

      def find_protonym
        Protonym.find(params.expect(:protonym_id))
      end
  end
end
