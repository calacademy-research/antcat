# frozen_string_literal: true

module DatabaseScripts
  class IdenticalAuthorNames < DatabaseScript
    def results
      AuthorName.group(:name).having("COUNT(id) > 1").pluck(:name)
    end

    def render
      as_table do |t|
        t.header 'Author names (author IDs)', '100% identical?', "Same author?"
        t.rows do |author_name_name|
          author_names = AuthorName.where(name: author_name_name)
          author_links = author_names.to_a.map do |author_name|
            link_label = "#{author_name.name} (##{author_name.author.id}) - #{author_name.references.count} references"
            link_to(link_label, author_path(author_name.author))
          end.join('<br>').html_safe
          more_than_one_author = author_names.map(&:author_id).uniq.size > 1

          [
            author_links,
            (author_names.to_a.map(&:name).uniq.size == 1 ? 'Yes' : bold_warning('No')),
            (more_than_one_author ? bold_warning('No') : 'Yes')
          ]
        end
      end
    end
  end
end

__END__

section: research
tags: [authors, postgres]

issue_description:

description: >
  Or "kinda identical". Names are compared without taking into account capitalization, diacritics, and such.

related_scripts:
  - AuthorsWithMultipleNames
  - IdenticalAuthorNames
  - VeryShortAuthorNames
