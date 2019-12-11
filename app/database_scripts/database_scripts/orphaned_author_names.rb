module DatabaseScripts
  class OrphanedAuthorNames < DatabaseScript
    def results
      AuthorName.left_outer_joins(:reference_author_names).where("reference_author_names.id IS NULL")
    end

    def render
      as_table do |t|
        t.header :id, :author
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

category: References
tags: [list]

description: >
  `AuthorName` records without `ReferenceAuthorName` records.

related_scripts:
  - OrphanedAuthorNames
  - OrphanedAuthors
  - OrphanedProtonyms
