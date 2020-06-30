# frozen_string_literal: true

module DatabaseScripts
  class ReferencesWithBlankPdfUrlsAndFilenames < DatabaseScript
    def results
      Reference.joins(:document).where(
        reference_documents: {
          file_file_name: ['', nil],
          url: ['', nil]
        }
      ).
      includes(:document, :author_names).references(:reference_author_names)
    end

    def render
      as_table do |t|
        t.header 'Reference', 'Document ID', 'Document created at', 'Document versions'
        t.rows do |reference|
          reference_document = reference.document

          [
            link_to(reference.key_with_citation_year, reference_path(reference)),
            reference_document.id,
            reference_document.created_at,
            document_versions_link(reference_document)
          ]
        end
      end
    end

    private

      def document_versions_link reference_document
        versions_count = reference_document.versions.count
        return if versions_count.zero?

        url = versions_path(item_type: 'ReferenceDocument', item_id: reference_document.id)
        link_to "#{versions_count} version(s)", url, class: 'btn-normal btn-tiny'
      end
  end
end

__END__

title: References with blank PDF URLs and filenames

section: pa-no-action-required
category: PDFs
tags: [slow-render]

description: >
  Once confirmed, the plan is to delete all these blank (unused) `ReferenceDocument` records.

related_scripts:
  - OrphanedReferenceDocuments
  - ProtonymReferencesWithoutPdfs
  - ReferenceDocumentsWithWeirdActualUrls
  - ReferencesWithBlankPdfUrlsAndFilenames
  - ReferencesWithoutPdfs
  - ReferencesWithPdfsNotHostedByUs
