module DatabaseScripts
  class NonDisplayableValidTaxa < DatabaseScript
    def results
      Taxon.valid.where(display: false)
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :display

        t.rows { |taxon| [ markdown_taxon_link(taxon), taxon.status, taxon.display ] }
      end
    end
  end
end

__END__

description: This page should be empty, since we should show all valid taxa.
tags: [regression-test]
topic_areas: [catalog]
