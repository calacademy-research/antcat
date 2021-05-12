# frozen_string_literal: true

module DatabaseScripts
  class NumberOfProtonymsByAuthor < DatabaseScript
    def empty_status
      DatabaseScripts::EmptyStatus::NOT_APPLICABLE
    end

    def statistics
      at_least_one_protonym = Author.joins(references: { citations: { protonym: :name } }).
        where("names.type IN (?)", Name::SPECIES_GROUP_NAMES)
      species_group_protonyms = Protonym.joins(:name).where(names: { type: [Name::SPECIES_GROUP_NAMES] })

      <<~STR.html_safe
        Authors with at least one SGN protonym (this list): #{at_least_one_protonym.distinct.count} <br>
        Authors (total in database): #{Author.count} <br>

        <br>

        Protonyms (total in database): #{Protonym.count} <br>
        Protonyms (SGN, total in database): #{species_group_protonyms.count} <br>
        Non-unique authors with at least one SGN protonym: #{at_least_one_protonym.count} <br>
      STR
    end

    # NOTE: SQL version of `names.type IN (?)` due to this:
    # ```
    #   author_join = Author.left_joins(references: { citations: { protonym: :name } })
    #
    #   author_join.where(names: { type: 'X' })
    #   ... FROM `authors` LEFT OUTER JOIN `author_names` names ON ...
    #   LEFT OUTER JOIN `names` `names_protonyms` ON ... WHERE `names`.`type` IN ...
    #
    #   author_join.where(names_protonyms: { type: 'X' })
    #   ... FROM `authors` LEFT OUTER JOIN `author_names` ON ...
    #   LEFT OUTER JOIN `names` ON ... WHERE `names_protonyms`.`type` = 'X'
    # ```
    def results
      Author.left_joins(references: { citations: { protonym: :name } }).
        where("names.type IN (?)", Name::SPECIES_GROUP_NAMES).
        group('authors.id').
        where.not(protonyms: { id: nil }).
        select("authors.id, COUNT(*) AS protonym_count")
    end

    def render
      as_table do |t|
        t.header 'Author', 'Protonym count'
        t.rows do |author|
          [
            link_to(author.first_author_name_name, author_path(author)),
            author[:protonym_count]
          ]
        end
      end
    end
  end
end

__END__

section: list
tags: [protonyms, stats]

description: >
  For protonyms described by more than one author, counts are increased once for each author,
  which is why "Non-unique authors with at least one SGN protonym" in the bluebox is higher
  than the total number of protonyms.


  Only species-group name protonyms are counted.

related_scripts:
  - NumberOfProtonymsByAuthor
