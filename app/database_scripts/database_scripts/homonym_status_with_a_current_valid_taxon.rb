module DatabaseScripts
  class HomonymStatusWithACurrentValidTaxon < DatabaseScript
    def results
      Taxon.where(status: Status::HOMONYM).where.not(current_valid_taxon_id: nil)
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :current_valid_taxon, :homonym_replaced_by, :same?
        t.rows do |taxon|
          [
            markdown_taxon_link(taxon),
            taxon.status,
            markdown_taxon_link(taxon.current_valid_taxon),
            markdown_taxon_link(taxon.homonym_replaced_by),
            (taxon.current_valid_taxon == taxon.homonym_replaced_by ? '-' : 'Yes')
          ]
        end
      end
    end
  end
end

__END__

description: >
  I'm not sure what to do here. Maybe we just don't set `current_valid_taxon` for homonyms, or require
  it to not be the same as the `homonym_replaced_by`.

tags: [new!]
topic_areas: [homonyms]
