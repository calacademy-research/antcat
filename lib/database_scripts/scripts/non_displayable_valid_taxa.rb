class DatabaseScripts::Scripts::NonDisplayableValidTaxa
  include DatabaseScripts::DatabaseScript

  def results
    Taxon.valid.where(display: false)
  end

  def render
    as_table do
      header :taxon, :status, :display
      rows { |taxon| [ markdown_taxon_link(taxon), taxon.status, taxon.display ] }
    end
  end
end

__END__

description: This page should be empty, since we should show all valid taxa.
tags: [new!, regression-test]
topic_areas: [catalog]
