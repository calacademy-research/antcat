# frozen_string_literal: true

# The base of the app's view components (app/components): adds the inline SVG helper that view_component 4 no longer
# gives.
class ApplicationComponent < ViewComponent::Base
  # view_component 4 no longer exposes helpers that gems add to `ActionView::Base`.
  include InlineSvg::ActionView::Helpers
end
