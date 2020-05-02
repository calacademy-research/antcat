# frozen_string_literal: true

module References
  class WhatLinksHere
    include Service

    attr_private_initialize :reference

    def all
      what_links_here_items
    end

    def any?
      return @_any if defined? @_any
      @_any ||= any_what_links_here_items?
    end

    private

      delegate :nestees, :citations, to: :reference, private: true

      def any_what_links_here_items?
        Taxt::TAXTABLES.each do |(model, _table, field)|
          return true if model.where("#{field} REGEXP ?", Taxt.ref_tag_regex(reference)).exists?
        end

        citations.exists? || nestees.exists?
      end

      def what_links_here_items
        wlh_items = []

        Taxt::TAXTABLES.each do |(model, _table, field)|
          model.where("#{field} REGEXP ?", Taxt.ref_tag_regex(reference)).pluck(:id).each do |matched_id|
            wlh_items << wlh_item(model.table_name, field.to_sym, matched_id)
          end
        end

        citations.pluck(:id).each do |citation_id|
          wlh_items << wlh_item(Citation.table_name, :reference_id, citation_id)
        end

        nestees.pluck(:id).each do |reference_id|
          wlh_items << wlh_item('references', :nesting_reference_id, reference_id)
        end

        wlh_items
      end

      def wlh_item table, field, id
        WhatLinksHereItem.new(table, field, id)
      end
  end
end
