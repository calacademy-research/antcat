# frozen_string_literal: true

module DatabaseScripts
  class OrphanedAuthorNames < DatabaseScript
    def results
      AuthorName.where.missing(:reference_author_names)
    end

    def render
      as_table do |t|
        t.header 'ID', 'Author'
        t.rows do |author_name|
          [
            author_name.author.id,
            link_to(author_name.name, author_path(author_name.author))
          ]
        end
      end
    end
  end
end

__END__

section: orphaned-records
tags: [authors, has-script]

description: >
  `AuthorName` records without `ReferenceAuthorName` records.

related_scripts:
  - OrphanedAuthorNames
  - OrphanedAuthors
  - OrphanedProtonyms
