module DatabaseScripts
  class ProtonymsToBeDeduped < DatabaseScript
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper

    def results
      grouped = Protonym.
        joins(:name, authorship: :reference).
        group('names.name, references.id, citations.pages, citations.forms, protonyms.locality, protonyms.fossil, protonyms.sic').
        having("COUNT(protonyms.id) > 1")

      # This does not work with NULLs, but let's start easy.
      Protonym.joins(:name, authorship: :reference).
        where(
          locality: grouped.select('protonyms.locality'),
          fossil: grouped.select('protonyms.fossil'),
          sic: grouped.select('protonyms.sic'),
          names: { name: grouped.select('names.name') },
          citations: {
            pages: grouped.select('citations.pages'),
            forms: grouped.select('citations.forms'),
            reference_id: grouped.select('references.id')
          }
        ).includes(:name).order('names.name')
    end

    def render
      as_table do |t|
        t.header :id, :protonym, :orphaned
        t.rows do |protonym|
          [
            protonym.id,
            link_to(protonym.decorate.format_name, protonym_path(protonym)),
            protonym.taxa.exists? ? "" : 'Yes'
          ]
        end
      end
    end
  end
end

__END__
description: >
  Candidates for merging by script. This script is a little bit WIP and will be refined as duplicates are merged and deleted.


  Same:


  * `names.name`

  * `references.id`

  * `citations.pages`

  * `citations.forms`

  * `protonyms.locality`

  * `protonyms.fossil`

  * `protonyms.sic`

tags: [new!, slow]
topic_areas: [protonyms]
