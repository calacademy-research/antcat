# frozen_string_literal: true

module Taxa
  class WhatLinksHere
    class Taxts
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
          Taxt::TAXTABLES.each do |(model, _table, field)|
            return true if model.where("#{field} REGEXP ?", Taxt.tax_or_taxac_tag_regex(taxon)).exists?
          end
          false
        end

        def what_links_here_items
          wlh_items = []
          Taxt::TAXTABLES.each do |(model, _table, field)|
            model.where("#{field} REGEXP ?", Taxt.tax_or_taxac_tag_regex(taxon)).pluck(:id).each do |matched_id|
              wlh_items << wlh_item(model.table_name, field.to_sym, matched_id)
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