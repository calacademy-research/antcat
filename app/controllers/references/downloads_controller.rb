module References
  class DownloadsController < ApplicationController
    before_action :set_reference_document

    def show
      if @reference_document.downloadable?
        redirect_to @reference_document.actual_url
      else
        head :unauthorized
      end
    end

    private

      def set_reference_document
        @reference_document = ReferenceDocument.find(params[:id])
      end
  end
end
