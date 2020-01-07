module DatabaseScripts
  class UnavailableUncategorizedTaxa < DatabaseScript
    def results
      Taxon.where(status: Status::UNAVAILABLE_UNCATEGORIZED).includes(:current_valid_taxon)
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :current_valid_taxon, :current_valid_taxon_status
        t.rows do |taxon|
          current_valid_taxon = taxon.current_valid_taxon

          [
            markdown_taxon_link(taxon),
            taxon.status,
            markdown_taxon_link(current_valid_taxon),
            current_valid_taxon.status
          ]
        end
      end
    end
  end
end

__END__

category: Catalog

issue_description: This taxon has the status "unavailable uncategorized".

description: >
  Taxa with the status `unavailable uncategorized`. We want to convert these to other statuses.

related_scripts:
  - AutoGeneratedTaxa
  - UnavailableMisspellings
  - UnavailableUncategorizedTaxaTouchedByEditors
  - UnavailableUncategorizedTaxa
