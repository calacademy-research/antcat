# TODO replace script with an "unresolved homonym" option
# in the catalog search form.

module DatabaseScripts
  class UnresolvedHomonyms < DatabaseScript
    def results
      Taxon.where(unresolved_homonym: true)
    end
  end
end

__END__
description: >
  These are more "taxonomical issues in science", rather than
  database issues on AntCat's side.
tags: [new!]
topic_areas: [catalog]
