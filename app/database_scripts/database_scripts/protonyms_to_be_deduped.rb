module DatabaseScripts
  class ProtonymsToBeDeduped < DatabaseScript
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper

    def results
      grouped = Protonym.
        joins(:name, authorship: :reference).
        group('names.name, references.id').
        having("COUNT(protonyms.id) > 1")

      Protonym.joins(:name, authorship: :reference).
        where(
          names: { name: grouped.select('names.name') },
          citations: {
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
  Version 3


  Candidates for merging by script.


  `citations.notes_taxt` is not checked in this script, but the deduping script will make sure they are either all the same,
  or only one unique `notes_taxt` and use that (this is called "Notes" in the protonym form).


  Same:


  * `names.name`

  * `references.id`


  Most probably same (not checked as they were fixed in the first batch of this script):


  * `protonyms.locality`

  * `protonyms.fossil`

  * `protonyms.sic`


  Different:


  * `citations.pages`

  * `citations.forms`


tags: [new!, slow]
topic_areas: [protonyms]
