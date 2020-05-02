# frozen_string_literal: true

module Taxa
  class WhatLinksHere
    class Columns
      COLUMNS_REFERENCING_TAXA = Taxa::WhatLinksHere::COLUMNS_REFERENCING_TAXA

      def initialize taxon
        @taxon = taxon
      end

      def all
        what_links_here_items
      end

      def any?
        return @_any if defined? @_any
        @_any ||= any_what_links_here_items?
      end

      private

        attr_reader :taxon

        def any_what_links_here_items?
          COLUMNS_REFERENCING_TAXA.each do |(model, column)|
            return true if model.where(column => taxon.id).exists?
          end
          false
        end

        def what_links_here_items
          wlh_items = []

          COLUMNS_REFERENCING_TAXA.each do |(model, column)|
            model.where(column => taxon.id).pluck(:id).each do |matched_id|
              wlh_items << wlh_item(model.table_name, column, matched_id)
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
