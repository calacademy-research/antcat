module References
  class DownloadsController < ApplicationController
    def show
      reference_document = find_reference_document

      if reference_document.downloadable?
        redirect_to reference_document.actual_url
      else
        head :unauthorized
      end
    end

    private

      def find_reference_document
        ReferenceDocument.find(params[:id])
      end
  end
end
