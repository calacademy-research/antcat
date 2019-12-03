module DatabaseScripts
  class ReplacementNamesUsedForMoreThanOneTaxon < DatabaseScript
    def results
      Taxon.where(
        homonym_replaced_by_id: Taxon.group(:homonym_replaced_by_id).having('COUNT(id) > 1').select(:homonym_replaced_by_id)
      )
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :replaced_by, :status_of_replaced_by
        t.rows do |taxon|
          [
            markdown_taxon_link(taxon),
            taxon.status,
            markdown_taxon_link(taxon.homonym_replaced_by),
            taxon.homonym_replaced_by.status
          ]
        end
      end
    end
  end
end

__END__

category: Catalog
tags: [new!]

description: >
