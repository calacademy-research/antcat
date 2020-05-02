# frozen_string_literal: true

module Taxa
  class WhatLinksHere
    class Columns
      include Service

      attr_private_initialize :taxon, [predicate: false]

      def call
        if predicate
          any_what_links_here_items?
        else
          what_links_here_items
        end
      end

      private

        def any_what_links_here_items?
          Taxa::WhatLinksHere::TAXA_COLUMNS_REFERENCING_TAXA.each do |field|
            return true if Taxon.where(field => taxon.id).exists?
          end
          false
        end

        def what_links_here_items
          wlh_items = []

          Taxa::WhatLinksHere::TAXA_COLUMNS_REFERENCING_TAXA.each do |field|
            Taxon.where(field => taxon.id).pluck(:id).each do |matched_id|
              wlh_items << wlh_item('taxa', field, matched_id)
            end
          end

          wlh_items
        end

        def wlh_item table, field, id
          WhatLinksHereItem.new(table, field, id)
        end
    end
  end
end
