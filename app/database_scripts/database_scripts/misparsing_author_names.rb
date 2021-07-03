# frozen_string_literal: true

module DatabaseScripts
  class MisparsingAuthorNames < DatabaseScript
    def empty_status
      DatabaseScripts::EmptyStatus::EXCLUDED
    end

    def results
      AuthorName.all.select do |author_name|
        Authors::ParseAuthorNames[author_name.name] != [author_name.name]
      end
    end

    def render
      as_table do |t|
        t.header 'AuthorName ID', 'Author', "Author's other names", 'Name', 'Parsed name', 'No. of references'
        t.rows do |author_name|
          author = author_name.author

          [
            author_name.id,
            link_to(author.first_author_name_name, author_path(author)),
            (author.names.map(&:name) - [author_name.name]).join('<br>'),
            author_name.name,
            Authors::ParseAuthorNames[author_name.name].first,
            author_name.references.count
          ]
        end
      end
    end
  end
end

__END__

title: Misparsing author names

section: research
tags: [authors, slow, new!]

description: >

related_scripts:
  - MisparsingAuthorNames
