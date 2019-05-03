module DatabaseScripts
  class ProtonymsWithSameNameRecord < DatabaseScript
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper

    def results
      same_name_id = Protonym.group(:name_id).having('COUNT(protonyms.id) > 1')
      Protonym.where(name_id: same_name_id.select(:name_id)).includes(:name).order('names.name')
    end

    def render
      as_table do |t|
        t.header :id, :protonym, :name_id_, :statuses_of_taxa, :any_unresolved_homonyms?
        t.rows do |protonym|
          taxa_statuses = protonym.taxa.pluck(:status)

          [
            protonym.id,
            link_to(protonym.decorate.format_name, protonym_path(protonym)),
            link_to(protonym.name.id, name_path(protonym.name)),
            taxa_statuses.present? ? taxa_statuses.join(', ') : '<span class="bold-warning">Orphaned protonym</span>',
            protonym.taxa.where(unresolved_homonym: true).exists? ? 'Yes' : ''
          ]
        end
      end
    end
  end
end

__END__

description: >
  Protonym records with the same name (`name_id`).


  Many of these are OK. Most that are not OK will appear in various other database scripts.


  It's still a little bit fuzzy to me how to identify true duplicates by script. Two different protonym records with the same name
  are probably duplicates if both taxa linked to the protonym are valid.
  If one the linked taxa has the status `homonym`, or `unresolved_homonym` set to true (this is
  the unresolved junior homonym checkbox in the taxon form), then the protonyms are likely not true duplicates and should not be merged.


  I think it's best to focus on other protonym scripts first.


  **How to fix**


  * Orphaned protonyms can be deleted or ignored

  * If the authorship is identical: change protonym of one and delete the now orphaned protonym

tags: [new!, slow]
topic_areas: [protonyms]
