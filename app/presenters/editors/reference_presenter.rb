# frozen_string_literal: true

module Editors
  class ReferencePresenter
    include Rails.application.routes.url_helpers
    include ActionView::Helpers
    include IconHelper

    attr_private_initialize :reference, [session: nil]

    def review_reference_button
      if can_finish_reviewing?
        link_to 'Finish reviewing', finish_reviewing_reference_path(reference),
          method: :post, class: "btn-saves btn-tiny"
      elsif can_start_reviewing?
        link_to 'Start reviewing', start_reviewing_reference_path(reference),
          method: :post, class: "btn-saves btn-tiny"
      elsif can_restart_reviewing?
        link_to 'Restart reviewing', restart_reviewing_reference_path(reference),
          method: :post, class: "btn-warning btn-tiny"
      end
    end

    def set_as_default_reference_button
      if reference == References::DefaultReference.get(session)
        tag.span ('Is default reference ' + antcat_icon('check')).html_safe, class: "btn-tiny",
          title: "This referece is set as the default reference."
      else
        link_to 'Make default', my_default_reference_path(id: reference.id),
          method: :put, class: "btn-saves btn-tiny"
      end
    end

    private

      def can_start_reviewing?
        reference.review_state == Reference::REVIEW_STATE_NONE
      end

      def can_finish_reviewing?
        reference.review_state == Reference::REVIEW_STATE_REVIEWING
      end

      def can_restart_reviewing?
        reference.review_state == Reference::REVIEW_STATE_REVIEWED
      end
  end
end
