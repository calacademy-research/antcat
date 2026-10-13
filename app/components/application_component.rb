# frozen_string_literal: true

class ApplicationComponent < ViewComponent::Base
  # view_component 4 no longer exposes helpers that gems add to `ActionView::Base`.
  include InlineSvg::ActionView::Helpers
end
