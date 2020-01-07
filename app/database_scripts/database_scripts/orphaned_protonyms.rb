module DatabaseScripts
  class OrphanedProtonyms < DatabaseScript
    def results
      Protonym.where.not(id: Taxon.select(:protonym_id))
    end
  end
end

__END__

category: Protonyms
tags: [list]

issue_description: This protonym is orphaned.

description: >
  Orphaned protonyms can be deleted by editors from the protonym page, or by script on request (see %github430).

related_scripts:
  - OrphanedAuthorNames
  - OrphanedAuthors
  - OrphanedProtonyms
