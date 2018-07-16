module References
  class WhatLinksHereController < ApplicationController
    before_action :set_reference, only: :index

    def index
      @table_refs = @reference.what_links_here
    end

    private

      def set_reference
        @reference = Reference.find params[:reference_id]
      end
  end
end
