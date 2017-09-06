# https://github.com/calacademy-research/antcat/issues/168

module DatabaseScripts
  class NonLatinCharactersInTaxonName < DatabaseScript
    def results
      Taxon.where("name_cache REGEXP ?", "[^A-Za-z -\\(\)]")
    end
  end
end

__END__
description: See also %github168.
topic_areas: [catalog]
