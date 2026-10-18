# frozen_string_literal: true

module References
  class WhatLinksHeresController < ApplicationController
    def show
      @reference = find_reference
      items = References::WhatLinksHere.new(@reference).all
      # Visitors do not see links that exist only inside hidden notes.
      items = WhatLinksHereVisibleItems[items, @reference, :reference] unless Current.signed_in
      @what_links_here_items = items.paginate(page: params[:page])
    end

    private

      def find_reference
        Reference.find(params.expect(:reference_id))
      end
  end
end
