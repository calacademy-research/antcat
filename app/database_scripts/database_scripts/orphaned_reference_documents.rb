module DatabaseScripts
  class OrphanedReferenceDocuments < DatabaseScript
    def results
      ReferenceDocument.where.not(reference_id: Reference.select(:id))
    end

    def render
      as_table do |t|
        t.header :document_id_, :reference_id_, :created_at, :versions, :reference_versions
        t.rows do |reference_document|
          [
            reference_document.id,
            reference_document.reference_id,
            reference_document.created_at,
            document_versions_link(reference_document),
            reference_versions_link(reference_document.reference_id)
          ]
        end
      end
    end

    private

      def document_versions_link reference_document
        versions_count = reference_document.versions.count
        return if versions_count == 0

        url = versions_path(item_type: 'ReferenceDocument', item_id: reference_document.id)
        link_to "#{versions_count} version(s)", url, class: 'btn-normal btn-tiny'
      end

      def reference_versions_link reference_id
        versions_count = PaperTrail::Version.where(item_type: 'Reference', item_id: reference_id).count
        return if versions_count == 0

        url = versions_path(item_type: 'Reference', item_id: reference_id)
        link_to "#{versions_count} version(s)", url, class: 'btn-normal btn-tiny'
      end
  end
end

__END__

description: >
   These can only be deleted by script.


   They can probably be safely deleted, but new cases can still appear when
   references with PDFs are deleted.


tags: [new!]
topic_areas: [pdfs]
related_scripts:
  - OrphanedReferenceDocuments
  - ProtonymReferencesWithoutPdfs
  - ReferencesWithBlankPdfUrlsAndFilenames
  - ReferencesWithoutPdfs
  - ReferencesWithPdfsNotHostedByUs
  - ReferencesWithUndownloadablePdfs
