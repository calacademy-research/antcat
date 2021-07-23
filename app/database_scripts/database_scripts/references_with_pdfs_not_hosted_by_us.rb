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
            reference_link(reference),
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
tags: [references, pdfs, slow-render]

description: >
  To be uploaded by script.

related_scripts:
  - ProtonymReferencesWithoutPdfs
  - ReferencesWithPdfsNotHostedByUs
