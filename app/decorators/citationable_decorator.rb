# frozen_string_literal: true

# The link to the record a citation belongs to (today always a protonym).
class CitationableDecorator
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper

  attr_private_initialize :citationable

  def link_to_citationable
    case citationable
    when Protonym then citationable.decorate.link_to_protonym
    else          raise "unknown citationable #{citationable.class.name}"
    end
  end
end
