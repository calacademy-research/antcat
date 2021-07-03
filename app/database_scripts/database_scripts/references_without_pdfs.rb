# frozen_string_literal: true

module DatabaseScripts
  class ReferencesWithoutPdfs < DatabaseScript
    def empty_status
      DatabaseScripts::EmptyStatus::EXCLUDED_LIST
    end

    def results
      Reference.left_outer_joins(:document).where(reference_documents: { id: nil }).
        order_by_author_names_and_year.
        includes(:author_names).references(:reference_author_names)
    end

    def render
      as_table do |t|
        t.header 'Reference'
        t.rows do |reference|
          [
            reference_link(reference)
          ]
        end
      end
    end
  end
end

__END__

title: References without PDFs

section: long-running
tags: [references, pdfs, slow-render]

description: >
  Issues: %github387, %github324, %github371

related_scripts:
  - OrphanedReferenceDocuments
  - ProtonymReferencesWithoutPdfs
  - ReferencesWithoutPdfs
  - ReferencesWithPdfsNotHostedByUs
