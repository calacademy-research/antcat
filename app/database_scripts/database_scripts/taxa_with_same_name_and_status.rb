module DatabaseScripts
  class TaxaWithSameNameAndStatus < DatabaseScript
    def results
      name_and_status = Taxon.joins(:name).group('names.name, status').having('COUNT(*) > 1')

      Taxon.joins(:name).
        where(names: { name: name_and_status.select(:name) }, status: name_and_status.select(:status)).
        order('names.name')
    end

    def render
      as_table do |t|
        t.header :taxon, :authorship, :status
        t.rows do |taxon|
          [
            markdown_taxon_link(taxon),
            taxon.authorship_reference.decorate.expandable_reference,
            taxon.status
          ]
        end
      end
    end
  end
end

__END__
topic_areas: [catalog]
tags: [list, updated!]
