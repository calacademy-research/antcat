# frozen_string_literal: true

module Editors
  class ReferencePresenter
    include Rails.application.routes.url_helpers
    include ActionView::Helpers

    attr_private_initialize :reference, [session: nil]

    def review_reference_button
      if reference.can_finish_reviewing?
        link_to 'Finish reviewing', finish_reviewing_reference_path(reference),
          method: :post, class: "btn-saves btn-tiny"
      elsif reference.can_start_reviewing?
        link_to 'Start reviewing', start_reviewing_reference_path(reference),
          method: :post, class: "btn-saves btn-tiny"
      elsif reference.can_restart_reviewing?
        link_to 'Restart reviewing', restart_reviewing_reference_path(reference),
          method: :post, class: "btn-warning btn-tiny"
      end
    end

    def set_as_default_reference_button
      if reference == References::DefaultReference.get(session)
        tag.span 'Default reference', class: "btn-nodanger btn-tiny",
          title: "This referece is set as the default reference."
      else
        link_to 'Make default', my_default_reference_path(id: reference.id),
          method: :put, class: "btn-saves btn-tiny"
      end
    end
  end
end
