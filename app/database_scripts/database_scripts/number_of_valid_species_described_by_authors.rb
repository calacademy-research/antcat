module DatabaseScripts
  class NumberOfValidSpeciesDescribedByAuthors < DatabaseScript
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper

    def results
      ActiveRecord::Base.connection.exec_query <<-SQL.squish
        SELECT a.id author_id, MAX(name) name, MIN(YEAR) min_year, MAX(year) max_year, COUNT(*) count FROM taxa
          JOIN protonyms ON taxa.protonym_id = protonyms.id
          JOIN citations ON protonyms.authorship_id = citations.id
          JOIN `references` ON citations.reference_id = `references`.id
          JOIN reference_author_names ran ON ran.reference_id = references.id
          JOIN author_names an ON ran.author_name_id = an.id
          JOIN authors a ON an.author_id = a.id
          WHERE taxa.type = 'Species' AND taxa.status = 'valid'
          GROUP BY author_id
          ORDER BY count DESC
      SQL
    end

    def render
      as_table do |t|
        t.header :name, :species_descriptions_between, :species_count

        t.rows do |row|
          years = "#{row['min_year']}&ndash;#{row['max_year']}"
          author_link = link_to row['name'], author_path(row['author_id'])

          [author_link, years, row['count']]
        end
      end
    end
  end
end

__END__
description: >
  Only valid taxa at the rank of species are included in this list.
  This also affects the year range and count.

topic_areas: [catalog]
