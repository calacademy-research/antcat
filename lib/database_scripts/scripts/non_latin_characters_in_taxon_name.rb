# https://github.com/calacademy-research/antcat/issues/168

class DatabaseScripts::Scripts::NonLatinCharactersInTaxonName
  include DatabaseScripts::DatabaseScript

  def results
    Taxon.where("name_cache REGEXP ?", "[^A-Za-z -\\(\)]")
  end
end

__END__
description: See also %github168.
topic_areas: [catalog]
