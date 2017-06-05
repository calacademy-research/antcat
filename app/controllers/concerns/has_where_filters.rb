# Usage:
#
# * Add `include FilterableWhere` to the model.
# * Add `include HasWhereFilters` to the controller.
# * Define `filters` in the controller.
# * Use `=render_filters` to render in views.
# * Filter with `Model#filter(filter_params)`.

module HasWhereFilters
  extend ActiveSupport::Concern

  included do
    class_attribute :filters
    helper_method :render_filters
  end

  module ClassMethods
    def has_filters filters
      self.filters = filters
    end
  end

  def render_filters
    render_to_string partial: "shared/filters", locals: { filters: filters }
  end

  private
    def filter_params
      params.slice *filters.keys
    end
end
