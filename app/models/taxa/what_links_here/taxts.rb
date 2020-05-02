# frozen_string_literal: true

module Taxa
  class WhatLinksHere
    class Taxts
      TAXT_TAG_METHOD = :tax_or_taxac_tag_regex

      def initialize taxon
        @taxon = taxon
        @taxt_tag = Taxt.public_send(TAXT_TAG_METHOD, taxon)
      end

      def all
        what_links_here_items
      end

      def any?
        return @_any if defined? @_any
        @_any ||= any_what_links_here_items?
      end

      private

        attr_reader :taxon, :taxt_tag

        def any_what_links_here_items?
          Taxt::TAXTABLES.each do |(model, _table, field)|
            return true if model.where("#{field} REGEXP ?", taxt_tag).exists?
          end
          false
        end

        def what_links_here_items
          wlh_items = []

          Taxt::TAXTABLES.each do |(model, _table, field)|
            model.where("#{field} REGEXP ?", taxt_tag).pluck(:id).each do |matched_id|
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
