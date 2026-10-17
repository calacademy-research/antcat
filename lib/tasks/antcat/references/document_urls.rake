# frozen_string_literal: true

namespace :antcat do
  namespace :references do
    desc "List reference documents whose legacy `url` is not http(s) (report only, changes nothing)"
    task documents_with_non_http_urls: [:environment] do
      documents = ReferenceDocument.with_non_http_url

      puts "Reference documents with a non-http(s) `url`: #{documents.size}"
      documents.each do |document|
        puts "  reference_documents.id #{document.id} (reference #{document.reference_id}): #{document.url.inspect}"
      end
    end
  end
end
