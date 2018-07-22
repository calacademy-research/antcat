module DatabaseScripts
  class NonHomonymsWithAHomonymReplacedById < DatabaseScript
    def results
      Taxon.where.not(status: Status::HOMONYM).where.not(homonym_replaced_by: nil)
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :homonym_replaced_by, :homonym_replaced_by_status

        t.rows do |taxon|
          [
            markdown_taxon_link(taxon),
            taxon.status,
            markdown_taxon_link(taxon.homonym_replaced_by),
            taxon.homonym_replaced_by.try(:status)
          ]
        end
      end
    end
  end
end

__END__
description: >
  Taxa on the left side have their `homonym_replaced_by_id` set to the right-side taxon.
  Note that the "Replaced by" button in the edit form is only visible when the when
  a taxon's status is set to "homonym".
topic_areas: [catalog]
