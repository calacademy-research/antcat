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
        t.header :id, :protonym, :other_id_, :other_protonym, :candidate?, :new_name, :action, :name_clash?
        t.rows do |(_authorship_id, protonym)|
          other_protonym = find_other_protonym protonym
          is_candidate = same_ish_name?(protonym, other_protonym)

          new_name = other_protonym.taxa.first.name.name.dup.gsub(/ /, ' i')

          name_clashes = if is_candidate && Taxon.name_clash?(new_name)
                           Taxon.where(name_cache: new_name)
                         end

          name_clash = if name_clashes
                         name_clashes.first.decorate.link_to_taxon
                       end

          add_i_to_or_delete = if name_clash
                                 'Delete: ' + other_protonym.taxa.first.decorate.link_to_taxon
                               else
                                 'Add i: ' + other_protonym.taxa.first.decorate.link_to_taxon
                               end

          [
            protonym.id,
            link_to(protonym.decorate.format_name, protonym_path(protonym)),
            other_protonym.id,
            link_to(other_protonym.decorate.format_name, protonym_path(other_protonym)),
            ('Yes' if is_candidate),
            (new_name if is_candidate),
            (add_i_to_or_delete if is_candidate),
            name_clash,
            ('warning, multiple name clashes' if name_clashes && name_clashes.count > 1)
          ]
        end
      end
    end

    private

      def find_other_protonym protonym
        Protonym.where.not(id: protonym.id).find_by(authorship_id: protonym.authorship_id)
      end

      # "Crematogaster (Crematogaster) isolata" is same-ish as "Crematogaster solata" (missing "i").
      def same_ish_name?(protonym, other_protonym)
        protonym.name.name.dup.gsub(/.*?\(/, '').remove(')').gsub(/ i/, ' ') == other_protonym.name.name
      end
  end
end

__END__
description: >
  Version 2.1 (missing "i"s)


  Candidates for merging by script.


  Protonym records with the same authorship record (`authorship_id` -- these should be unique, one per protonym).
  One in each row is probably a duplicate.

tags: [slow]
topic_areas: [protonyms]
