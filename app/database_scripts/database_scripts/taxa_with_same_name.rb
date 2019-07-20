module DatabaseScripts
  class TaxaWithSameName < DatabaseScript
    def results
      same_name = Taxon.joins(:name).group('names.name').having('COUNT(*) > 1')

      Taxon.joins(:name).where(names: { name: same_name.select(:name) }).order('names.name')
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
tags: [list]
related_scripts:
  - TaxaWithSameName
  - TaxaWithSameNameAndStatus
  - ProtonymsWithSameName
