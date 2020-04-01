# frozen_string_literal: true

module Exporters
  module Antweb
    class AntwebInlineCitation
      include ActionView::Helpers::UrlHelper
      include Service

      attr_private_initialize :reference

      def call
        [reference_link, document_links].reject(&:blank?).join(' ').html_safe
      end

      private

        def reference_link
          link_to reference.keey.html_safe, reference_url, title: Unitalicize[plain_text]
        end

        def document_links
          reference.decorate.format_document_links
        end

        def reference_url
          "#{Settings.production_url}/references/#{reference.id}"
        end

        def plain_text
          reference.decorate.plain_text
        end
    end
  end
end
