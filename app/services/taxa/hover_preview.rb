# frozen_string_literal: true

module Taxa
  class HoverPreview
    include Service

    attr_private_initialize :taxon

    def call
      parts = []
      parts << nomen_synopsis
      parts << ''
      parts << protonym_synopsis
      parts.join('<br>').html_safe
    end

    private

      delegate :protonym, :authorship_reference, to: :taxon, private: true

      def nomen_synopsis
        [
          '<b>Name:</b> ' + CatalogFormatter.link_to_taxon(taxon),
          '<b>Author citation:</b> ' + taxon.author_citation,
          '<b>Rank:</b> ' + taxon.type,
          '<b>Status:</b> ' + taxon.decorate.expanded_status
        ].join('<br>')
      end

      def protonym_synopsis
        [
          '<b>Protonym:</b> ' + decorated_protonym.link_to_protonym,
          '<b>Authorship:</b> ' + authorship
        ].join('<br>')
      end

      def authorship
        authorship_reference.decorate.link_to_reference + ': ' + decorated_protonym.format_pages_and_forms
      end

      def decorated_protonym
        @_decorated_protonym ||= protonym.decorate
      end
  end
end
