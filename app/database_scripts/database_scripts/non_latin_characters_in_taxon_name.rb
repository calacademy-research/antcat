module DatabaseScripts
  class NonLatinCharactersInTaxonName < DatabaseScript
    def results
      Taxon.where("name_cache REGEXP ?", "[^-A-Za-z \(\)]")
    end
  end
end

__END__
description: >
  Valid characters: A-Z, a-z, `(`, `)`
tags: [list, updated!]
topic_areas: [names]
