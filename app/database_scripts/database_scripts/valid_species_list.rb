module DatabaseScripts
  class ValidSpeciesList < DatabaseScript
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper

    include DatabaseScripts::Renderers::AsCSV

    HEADERS = [:subfamily, :genus, :species, :author_year,
      :author_citation, :fossil, :status, :antcat_id]

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
        t.rows(results.limit(1)) do |taxon|
          [
            taxon.try(:subfamily).try(:name_cache),
            taxon.try(:genus).try(:name_html_cache),
            link_taxon(taxon),
            author_year(taxon),
            taxon.authorship_string,
            taxon.fossil?,
            taxon.status,
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
            taxon.try(:subfamily).try(:name_cache),
            taxon.try(:genus).try(:name_cache),
            taxon.name_cache,
            author_year(taxon),
            taxon.authorship_string,
            taxon.fossil?,
            taxon.status,
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
        taxon.protonym.authorship.reference.try(:year)
      end

      def link_taxon taxon
        return unless taxon
        taxon.decorate.link_to_taxon
      end
  end
end

__END__
description: >
  List of all valid species. Suitable for exporting to `.csv` (see %github161).


  The HTML version of this script is disabled because it's very slow
  (only the first species is shown as an example).


  `# TODO make catalog search results exportable as CSV, making this script redundant.`

tags: [new!, very-slow, csv]
topic_areas: [catalog]
