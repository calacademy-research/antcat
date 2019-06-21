module DatabaseScripts
  class ValidSpeciesList < DatabaseScript
    include DatabaseScripts::Renderers::AsCSV

    HEADERS = [:subfamily, :genus, :species, :author_year,
      :author_citation, :fossil, :status, :biogeographic_region,
      :locality, :antcat_id]

    def results
      Species.valid.
        includes(:name).
        includes(:subfamily).
        includes(:genus).
        includes(protonym: :name).
        includes(protonym: { authorship: { reference: :author_names } }).
        references(:reference_author_names)
    end

    def render
      to_html
    end

    def to_html
      as_table do |t|
        t.header *HEADERS

        # Disabled for performance reasons, but it should be:
        # `t.rows(find_each: true) do |taxon|`
        t.rows(cached_results.limit(1)) do |taxon|
          [
            taxon&.subfamily&.name_cache,
            taxon&.genus&.name_html_cache,
            link_taxon(taxon),
            author_year(taxon),
            taxon.author_citation,
            taxon.fossil?,
            taxon.status,
            taxon.protonym.biogeographic_region,
            taxon.protonym.locality,
            taxon.id
          ]
        end
      end
    end

    def to_csv
      as_csv do |c|
        c.header *HEADERS

        c.rows(find_each: true) do |taxon|
          [
            taxon&.subfamily&.name_cache,
            taxon&.genus&.name_cache,
            taxon.name_cache,
            author_year(taxon),
            taxon.author_citation,
            taxon.fossil?,
            taxon.status,
            taxon.protonym.biogeographic_region,
            taxon.protonym.locality,
            taxon.id
          ]
        end
      end
    end

    private

      # HACK to fix `as_table` issue...
      def cached_render
        nil
      end

      def author_year taxon
        taxon.authorship_reference&.year
      end

      def link_taxon taxon
        return unless taxon
        taxon.link_to_taxon
      end
  end
end

__END__
description: >
  List of all valid species. Suitable for exporting to `.csv` (see %github161).


  The HTML version of this script is disabled because it's very slow
  (only the first species is shown as an example).


  `# TODO make catalog search results exportable as CSV, making this script redundant.`

tags: [list, very-slow, csv]
topic_areas: [catalog]
