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

related_scripts:
  - OrphanedAuthorNames
  - OrphanedAuthors
  - OrphanedProtonyms
