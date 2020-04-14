# frozen_string_literal: true

module DatabaseScripts
  class OrphanedAuthors < DatabaseScript
    def results
      Author.distinct.left_outer_joins(:references).where('references.id IS NULL').
        includes(:names)
    end

    def render
      as_table do |t|
        t.header 'ID', 'Author', 'No. of references'
        t.rows do |author|
          [
            author.id,
            link_to(author.first_author_name_name, author_path(author)),
            author.references.count
          ]
        end
      end
    end
  end
end

__END__

section: orphaned-records
category: References
tags: []

description: >
  Non-orphaned authors with references in this list indicates that at least one of their author names has no references.

related_scripts:
  - OrphanedAuthorNames
  - OrphanedAuthors
  - OrphanedProtonyms
