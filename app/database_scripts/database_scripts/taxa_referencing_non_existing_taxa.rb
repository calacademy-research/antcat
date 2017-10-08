module DatabaseScripts
  class TaxaReferencingNonExistingTaxa < DatabaseScript
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper

    def genus_id_results
      Taxon.where('genus_id NOT IN (SELECT id FROM taxa)')
    end

    def homonym_replaced_by_id_results
      Taxon.where('homonym_replaced_by_id NOT IN (SELECT id FROM taxa)')
    end

    def current_valid_taxon_id_results
      Taxon.where('current_valid_taxon_id NOT IN (SELECT id FROM taxa)')
    end

    def render
      as_table do |t|
        t.header :non_existing_genus_id, :taxon, :status, :search_history?

        t.rows(genus_id_results) do |taxon|
          [
            taxon.genus_id,
            markdown_taxon_link(taxon),
            taxon.status,
            search_history_link(taxon.genus_id)
          ]
        end
      end <<

        as_table do |t|
          t.header :non_existing_homonym_replaced_by_id, :taxon, :status, :search_history?

          t.rows(homonym_replaced_by_id_results) do |taxon|
            [
              taxon.homonym_replaced_by_id,
              markdown_taxon_link(taxon),
              taxon.status,
              search_history_link(taxon.homonym_replaced_by_id)
            ]
          end
        end <<

        as_table do |t|
          t.header :non_existing_current_valid_taxon_id, :taxon, :status, :search_history?

          t.rows(current_valid_taxon_id_results) do |taxon|
            [
              taxon.current_valid_taxon_id,
              markdown_taxon_link(taxon),
              taxon.status,
              search_history_link(taxon.current_valid_taxon_id)
            ]
          end
        end
    end

    def search_history_link id
      link_to "Search history", versions_path(item_id: id), class: "btn-normal btn-tiny"
    end
  end
end

__END__
# The end data will be parsed as YAML, so hashtag comments are OK here.
description: >
  The columns included in this check are `genus_id`, `homonym_replaced_by_id`
  and `homonym_replaced_by_id`, because (as of writing), these are the only
  fields in the `taxa` table referring to non-existing `taxa` records.

tags: [new!]
topic_areas: [catalog]
