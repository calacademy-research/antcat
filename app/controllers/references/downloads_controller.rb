# frozen_string_literal: true

module References
  class DownloadsController < ApplicationController
    def show
      reference_document = find_reference_document
      redirect_to reference_document.actual_url, allow_other_host: true
    rescue References::DocumentStorage::NotConfigured
      render plain: "This document is not available on this server (file storage is not configured).",
        status: :service_unavailable
    end

    private

      def find_reference_document
        ReferenceDocument.find(params.expect(:id))
      end
  end
end
