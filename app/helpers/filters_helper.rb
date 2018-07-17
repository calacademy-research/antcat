module FiltersHelper
  def render_filters(&block)
    extra_fields = if block_given? then capture(&block) end
    render "shared/filters", filters: controller.filters, extra_fields: extra_fields
  end
end
