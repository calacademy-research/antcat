# frozen_string_literal: true

module DatabaseScripts
  class OrphanedProtonyms < DatabaseScript
    def results
      Protonym.where.not(id: Taxon.select(:protonym_id)).includes(:name)
    end
  end
end

__END__

section: list
category: Protonyms
tags: []

issue_description: This protonym is orphaned.

description: >
  Orphaned protonyms can be deleted by editors from the protonym page, or by script on request (see %github430).

related_scripts:
  - OrphanedAuthorNames
  - OrphanedAuthors
  - OrphanedProtonyms
