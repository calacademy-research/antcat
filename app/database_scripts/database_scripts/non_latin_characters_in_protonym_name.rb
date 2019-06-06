module DatabaseScripts
  class NonLatinCharactersInProtonymName < DatabaseScript
    def results
      Protonym.joins(:name).where("names.name REGEXP ?", "[^-.A-Za-z \(\)]")
    end
  end
end

__END__
description: >
  Valid characters: A-Z, a-z, `.`, `(`, `)`
tags: [list, new!]
topic_areas: [names]
