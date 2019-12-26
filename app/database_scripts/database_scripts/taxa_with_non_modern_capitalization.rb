module DatabaseScripts
  class TaxaWithNonModernCapitalization < DatabaseScript
    def results
      Taxon.joins(:name).where("name NOT LIKE '%(%' AND BINARY SUBSTRING(name, 2) != LOWER(SUBSTRING(name, 2))")
    end
  end
end

__END__

title: Taxa with non-modern capitalization
category: Catalog
tags: [new!]

issue_description: The name of this taxon contains non-modern capitalization.

description: >

related_scripts:
  - SameNamedPassThroughNames
  - TaxaWithNonModernCapitalization
  - TaxaWithSameName
  - TaxaWithSameNameAndStatus
  - ProtonymsWithSameName
  - ProtonymsWithSameNameExcludingSubgenusPart
