# frozen_string_literal: true

module DatabaseScripts
  class ReferenceDocumentsWithWeirdActualUrls < DatabaseScript
    def results
      broken_ids = ReferenceDocument.where.not(file_file_name: ['', nil]).to_a.reject do |document|
        document.url.blank? || (document.url == document.__send__(:url_via_file_file_name))
      end.map(&:id)

      ReferenceDocument.where(id: broken_ids)
    end

    def render
      as_table do |t|
        t.header 'Document ID', 'Created at', 'Reference', 'Kinda same?', 'Generated URL / Filename / URL'
        t.rows do |reference_document|
          [
            reference_document.id,
            reference_document.created_at,
            (reference_document.reference ? reference_document.reference.decorate.link_to_reference : '(none)'),
            (kinda_same?(reference_document) ? 'Yes' : 'No'),
            <<~STR
              #{link_it reference_document.__send__(:url_via_file_file_name)}<br>
              #{reference_document.file_file_name}<br>
              #{link_it reference_document.url}
            STR
          ]
        end
      end
    end

    private

      def link_it url
        link_to url, url
      end

      def kinda_same? reference_document
        normalize_url(reference_document.__send__(:url_via_file_file_name)) ==
          normalize_url(reference_document.url)
      end

      def normalize_url url
        url.
          gsub(/https/, '').
          gsub(/http/, '').
          gsub(/www./, '').
          gsub(%r{://}, '').
          gsub(%r{antcat.org/documents/}, '')
      end
  end
end

__END__

title: Reference documents with weird <code>actual_url</code>s

section: pa-no-action-required
category: PDFs
tags: []

description: >

related_scripts:
  - OrphanedReferenceDocuments
  - ProtonymReferencesWithoutPdfs
  - ReferenceDocumentsWithWeirdActualUrls
  - ReferencesWithBlankPdfUrlsAndFilenames
  - ReferencesWithoutPdfs
  - ReferencesWithPdfsNotHostedByUs
