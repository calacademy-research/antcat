# frozen_string_literal: true

module DatabaseScripts
  class ProtonymReferencesWithoutPdfs < DatabaseScript
    def empty_status
      DatabaseScripts::EmptyStatus::EXCLUDED_LIST
    end

    def results
      Reference.where(id: Citation.select(:reference_id)).
        left_joins(:document).where(reference_documents: { id: nil }).
        order_by_author_names_and_year
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

title: Protonym references without PDFs

section: list
tags: [references, pdfs, protonyms]

description: >

related_scripts:
  - ProtonymReferencesWithoutPdfs
  - ReferencesWithPdfsNotHostedByUs
