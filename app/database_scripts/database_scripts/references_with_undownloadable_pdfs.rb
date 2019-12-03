module DatabaseScripts
  class ReferencesWithUndownloadablePdfs < DatabaseScript
    def results
      reference_document_ids = ReferenceDocument.all.to_a.reject(&:downloadable?).map(&:id)
      Reference.joins(:document).where(reference_documents: { id: reference_document_ids })
    end

    def render
      as_table do |t|
        t.header :reference, :url, :created_at, :versions
        t.rows do |reference|
          reference_document = reference.document

          [
            link_to(reference.keey, reference_path(reference)),
            link_to(reference_document.url, reference_document.url),
            reference_document.created_at,
            versions_link(reference_document)
          ]
        end
      end
    end

    private

      def versions_link reference_document
        versions_count = reference_document.versions.count
        return if versions_count == 0

        url = versions_path(item_type: 'ReferenceDocument', item_id: reference_document.id)
        link_to "#{versions_count} version(s)", url, class: 'btn-normal btn-tiny'
      end
  end
end

__END__

title: References with undownloadable PDFs
category: PDFs
tags: [new!, slow]

description: >
  "Downloadable" is defined as `url.present? && !hosted_by_antbase? && !hosted_by_hol?`,


  Where `hosted_by_antbase?` means URLs starting with `http(s)://antbase.org`, and

  `hosted_by_hol?` means URLs starting with `http(s)://128.146.250.117`.

related_scripts:
  - OrphanedReferenceDocuments
  - ProtonymReferencesWithoutPdfs
  - ReferencesWithBlankPdfUrlsAndFilenames
  - ReferencesWithoutPdfs
  - ReferencesWithPdfsNotHostedByUs
  - ReferencesWithUndownloadablePdfs
