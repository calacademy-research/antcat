module DatabaseScripts
  class ProtonymsWithSameNameAndReference < DatabaseScript
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
          citations: { reference_id: grouped.select('references.id') }
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
  Protonym records with the same name (name value) and reference (`reference_id`).
  One in each row is probably a duplicate.


  **How to fix**


  * Figure out which is correct protonym

  * Go the the protonym page of the incorrect protonym, and edit each taxon in the "Taxa belonging to this protonym" section, so that the protonym is the correct protonym (you can paste the ID of the correct protonym in the protonym select box).

  * *Optional*: Delete the incorrect and now orphaned protonym (the delete button is only visible for orphaned protonyms). Optional because we can delete all orphans via script.


tags: [new!]
topic_areas: [catalog]
