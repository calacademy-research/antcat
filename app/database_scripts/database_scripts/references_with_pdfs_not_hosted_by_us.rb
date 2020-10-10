# frozen_string_literal: true

module DatabaseScripts
  class ReferencesWithPdfsNotHostedByUs < DatabaseScript
    def empty_status
      DatabaseScripts::EmptyStatus::EXCLUDED
    end

    def results
      Reference.left_outer_joins(:document).
        where.not(reference_documents: { url: [nil, ''] }).
        where("url NOT LIKE ?", "%antcat.org/documents%").
        order_by_author_names_and_year.
        includes(:author_names).references(:reference_author_names)
    end

    def render
      as_table do |t|
        t.header 'Reference', 'URL', 'Protonym reference?'
        t.rows do |reference|
          [
            link_to(reference.key_with_suffixed_year, reference_path(reference)),
            link_to(reference.document.url, reference.document.url),
            ('Yes' if reference.citations.any?)
          ]
        end
      end
    end
  end
end

__END__

title: References with PDFs not hosted by us

section: pa-no-action-required
category: PDFs
tags: [slow-render]

description: >
  Once confirmed, the plan is to upload all externally hosted documents to S3, where
  all other references are hosted  (TODO: write script).


  This list does not take into account `ReferenceDocument`s with both a `url` and
  a `file_file_name` (URLs are ignored for documents with both).


  Issues: %github387, %github324, %github371

related_scripts:
  - OrphanedReferenceDocuments
  - ProtonymReferencesWithoutPdfs
  - ReferenceDocumentsWithWeirdActualUrls
  - ReferencesWithBlankPdfUrlsAndFilenames
  - ReferencesWithoutPdfs
  - ReferencesWithPdfsNotHostedByUs
