module PrimitiveSearch
  extend ActiveSupport::Concern

  included do
    class_attribute :primitive_search_where

    scope :search_objects, ->(search_params) do
      search_type = search_params[:search_type].presence || "LIKE"
      raise unless search_type.in? ["LIKE", "REGEXP"]

      q = search_params[:q]
      q = "%#{q}%" if search_type == "LIKE"

      where(primitive_search_where[search_type], q: q)
    end
  end

  module ClassMethods
    def has_primitive_search(where:)
      self.primitive_search_where = where
    end
  end
end
