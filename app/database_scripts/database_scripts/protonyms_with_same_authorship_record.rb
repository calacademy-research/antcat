module DatabaseScripts
  class ProtonymsWithSameAuthorshipRecord < DatabaseScript
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper

    def results
      same_authorship = Protonym.group(:authorship_id).having("COUNT(protonyms.id) > 1")

      Protonym.where(authorship_id: same_authorship.select(:authorship_id)).
        includes(:name).order('names.name').
        index_by(&:authorship_id) # HACK-ish way of only showing each duplicate once.
    end

    def render
      as_table do |t|
        t.header :id, :protonym, :other_id_, :other_protonym
        t.rows do |(_authorship_id, protonym)|
          other_protonym = find_other_protonym protonym

          [
            protonym.id,
            link_to(protonym.decorate.format_name, protonym_path(protonym)),
            other_protonym.id,
            link_to(other_protonym.decorate.format_name, protonym_path(other_protonym))
          ]
        end
      end
    end

    private

      def find_other_protonym protonym
        Protonym.where.not(id: protonym.id).find_by(authorship_id: protonym.authorship_id)
      end
  end
end

__END__
description: >
  Protonym records with the same authorship record (`authorship_id`).


  **How to fix**


  * Figure out which is correct protonym

  * Go the the protonym page of the incorrect protonym, and edit each taxon in the "Taxa belonging to this protonym" section, so that the protonym is the correct protonym (you can paste the ID of the correct protonym in the protonym select box).

  * *Optional*: Delete the incorrect and now orphaned protonym (the delete button is only visible for orphaned protonyms). Optional because we can delete all orphans via script.

tags: [slow, new!]
topic_areas: [catalog]
