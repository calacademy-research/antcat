module DatabaseScripts
  class ProtonymsWithSameAuthorshipRecord < DatabaseScript
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper

    def results
      same_authorship = Protonym.group(:authorship_id).having("COUNT(protonyms.id) > 1")

      Protonym.where(authorship_id: same_authorship.select(:authorship_id)).
        order(id: :desc).
        includes(:name).order('names.name').
        index_by(&:authorship_id) # HACK-ish way of only showing each duplicate once.
    end

    def render
      as_table do |t|
        t.header :id, :protonym, :other_id_, :other_protonym, :candidate?, :locality, :other_locality
        t.rows do |(_authorship_id, protonym)|
          other_protonym = find_other_protonym protonym

          [
            protonym.id,
            link_to(protonym.decorate.format_name, protonym_path(protonym)),
            other_protonym.id,
            link_to(other_protonym.decorate.format_name, protonym_path(other_protonym)),
            (same_ish_name?(protonym, other_protonym) ? 'Yes' : ''),
            protonym.locality.presence || '-',
            other_protonym.locality.presence || '-'
          ]
        end
      end
    end

    private

      def find_other_protonym protonym
        Protonym.where.not(id: protonym.id).find_by(authorship_id: protonym.authorship_id)
      end

      # "Camponotus (Tanaemyrmex) ruseni" is same-ish as "Tanaemyrmex ruseni".
      def same_ish_name?(protonym, other_protonym)
        protonym.name.name.dup.gsub(/.*?\(/, '').remove(')') == other_protonym.name.name
      end
  end
end

__END__
description: >
  Version 1


  Candidates for merging by script.


  Protonym records with the same authorship record (`authorship_id` -- these should be unique, one per protonym).
  One in each row is probably a duplicate.

tags: [slow]
topic_areas: [protonyms]
