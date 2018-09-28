module References
  class DownloadsController < ApplicationController
    def show
      document = ReferenceDocument.find params[:id]
      if document.downloadable?
        redirect_to document.actual_url
      else
        head :unauthorized
      end
    end
  end
end
