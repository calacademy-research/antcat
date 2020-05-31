# frozen_string_literal: true

module DatabaseScripts
  class IdenticalAuthorNames < DatabaseScript
    def results
      AuthorName.group(:name).having("COUNT(id) > 1").pluck(:name)
    end

    def render
      as_table do |t|
        t.header 'Author name', 'Author (IDs with links)'
        t.rows do |author_name_name|
          authors = Author.joins(:names).where(author_names: { name: author_name_name })

          [
            author_name_name,
            authors.map { |author| link_to "##{author.id}", author_path(author) }.join('<br>')
          ]
        end
      end
    end
  end
end

__END__

section: main
category: References
tags: [new!]

issue_description:

description: >

related_scripts:
  - AuthorsWithMultipleNames
  - IdenticalAuthorNames
