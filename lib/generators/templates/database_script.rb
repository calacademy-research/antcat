class DatabaseScripts::Scripts::<%= class_name %>
  include DatabaseScripts::DatabaseScript

  def results
    # Subspecies.where(species: nil, auto_generated: false)
  end

  # When this method isn't implemented, the code tries to figure out
  # how to render `results` based on its class.
  def render
    # as_table do
    #   header :subspecies, :status
    #   rows { |taxon| [ markdown_taxon_link(taxon), taxon.status ] }
    # end
  end
end

__END__
description: Script description; optional, defaults to the humanized class name
tags: [example-tag] # optional
