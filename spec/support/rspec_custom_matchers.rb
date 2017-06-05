RSpec::Matchers.define :have_formatted_review_state do |expected|
  match do |reference|
    actual = reference.decorate.format_review_state
    actual == expected
  end
end

RSpec::Matchers.define :have_valid_where_filters do
  match do |controller|
    raise "Must have at least one filter." if controller.filters.size.zero?

    unless controller.render_filters.present?
      raise "Cannot render filter partial. Is `render_views` enabled?"
    end

    true
  end
end
