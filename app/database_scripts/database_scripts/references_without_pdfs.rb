module DatabaseScripts
  class ReferencesWithoutPdfs < DatabaseScript
    def results
      Reference.left_outer_joins(:document).where(reference_documents: { id: nil }).
        no_missing.order_by_author_names_and_year
    end

    def render
      as_table do |t|
        t.header :reference
        t.rows do |reference|
          [
            link_to(reference.keey, reference_path(reference))
          ]
        end
      end
    end
  end
end

__END__

description: >
  Issues: %github387, %github324, %github371

tags: [slow]
topic_areas: [pdfs]
related_scripts:
  - ReferencesWithoutPdfs
  - ProtonymReferencesWithoutPdfs
  - ReferencesWithPdfsNotHostedByUs
