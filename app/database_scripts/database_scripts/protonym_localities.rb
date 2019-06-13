module DatabaseScripts
  class ProtonymLocalities < DatabaseScript
    def results
      Protonym.distinct.pluck(:locality).reject(&:blank?).sort
    end

    def render
      as_table do |t|
        t.header :locality, :search_link
        t.rows do |locality|
          [
            locality,
            search_link(locality)
          ]
        end
      end
    end

    private

      def search_link locality
        link_to 'Search', catalog_search_path(locality: locality, submit_search: 'yes'), class: 'btn-normal btn-tiny'
      end
  end
end

__END__
description: >
  This script is just lists of all unique protonym `locality`s.
tags: [list]
topic_areas: [types]
