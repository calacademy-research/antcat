# frozen_string_literal: true

module References
  class DownloadsController < ApplicationController
    def show
      reference_document = find_reference_document
      redirect_to reference_document.actual_url, allow_other_host: true
    end

    private

      def find_reference_document
        ReferenceDocument.find(params[:id])
      end
  end
end
