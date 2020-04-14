# frozen_string_literal: true

module DatabaseScripts
  class OrphanedReferenceDocuments < DatabaseScript
    def results
      ReferenceDocument.where.not(reference_id: Reference.select(:id))
    end

    def render
      as_table do |t|
        t.header 'Document ID', 'Reference ID', 'Created at', 'Versions', 'Reference versions'
        t.rows do |document|
          [
            document.id,
            (document.reference ? document.reference.decorate.link_to_reference : "[deleted] #{document.reference_id}"),
            document.created_at,
            document_versions_link(document),
            reference_versions_link(document.reference_id)
          ]
        end
      end
    end

    private

      def document_versions_link document
        versions_count = document.versions.count
        return if versions_count.zero?

        url = versions_path(item_type: 'ReferenceDocument', item_id: document.id)
        link_to "#{versions_count} version(s)", url, class: 'btn-normal btn-tiny'
      end

      def reference_versions_link reference_id
        versions_count = PaperTrail::Version.where(item_type: 'Reference', item_id: reference_id).count
        return if versions_count.zero?

        url = versions_path(item_type: 'Reference', item_id: reference_id)
        link_to "#{versions_count} version(s)", url, class: 'btn-normal btn-tiny'
      end
  end
end

__END__

section: orphaned-records
category: PDFs

description: >
   These can only be deleted by script.


   They can probably be safely deleted, but new cases can still appear when
   references with PDFs are deleted.

related_scripts:
  - OrphanedReferenceDocuments
  - ProtonymReferencesWithoutPdfs
  - ReferencesWithBlankPdfUrlsAndFilenames
  - ReferencesWithoutPdfs
  - ReferencesWithPdfsNotHostedByUs
