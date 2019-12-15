module References
  class WhatLinksHeresController < ApplicationController
    before_action :set_reference, only: :show

    def show
      @table_refs = @reference.what_links_here.paginate(page: params[:page])
    end

    private

      def set_reference
        @reference = Reference.find(params[:reference_id])
      end
  end
end
