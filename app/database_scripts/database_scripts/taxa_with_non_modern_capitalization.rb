module DatabaseScripts
  class TaxaWithNonModernCapitalization < DatabaseScript
    def results
      Taxon.joins(:name).where("name NOT LIKE '%(%' AND BINARY SUBSTRING(name, 2) != LOWER(SUBSTRING(name, 2))")
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :suggested_name
        t.rows do |taxon|
          suggested_name = Names::BuildNameFromString[taxon.name_cache.downcase.capitalize]
          [
            markdown_taxon_link(taxon),
            taxon.status,
            suggested_name.name_html
          ]
        end
      end
    end
  end
end

__END__

title: Taxa with non-modern capitalization
category: Catalog
tags: [new!]

issue_description: The name of this taxon contains non-modern capitalization.

description: >
  Names can be updated to the suggested name by script.

related_scripts:
  - SameNamedPassThroughNames
  - TaxaWithNonModernCapitalization
  - TaxaWithSameName
  - TaxaWithSameNameAndStatus
  - ProtonymsWithSameName
  - ProtonymsWithSameNameExcludingSubgenusPart
