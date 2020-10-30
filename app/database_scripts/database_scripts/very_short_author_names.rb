# frozen_string_literal: true

module DatabaseScripts
  class VeryShortAuthorNames < DatabaseScript
    def results
      AuthorName.where("LENGTH(name) < 6")
    end

    def render
      as_table do |t|
        t.header 'ID', 'Author', 'Num. references (of this AuthorName)',
          'Num. references (of author except this AuthorName)', 'Other names of author'
        t.rows do |author_name|
          author = author_name.author
          other_names_of_author = author.names.pluck(:name) - [author_name.name]

          num_author_name_refs = author_name.references.count
          num_author_refs = author.references.count

          [
            author_name.author.id,
            link_to(author_name.name, author_path(author_name.author)),
            num_author_name_refs,
            (num_author_refs - num_author_name_refs),
            other_names_of_author.join('<br>')
          ]
        end
      end
    end
  end
end

__END__

section: research
category: References
tags: [new!]

issue_description:

description: >

related_scripts:
  - AuthorsWithMultipleNames
  - IdenticalAuthorNames
  - VeryShortAuthorNames
