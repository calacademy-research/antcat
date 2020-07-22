# frozen_string_literal: true

class CitationableDecorator
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper

  attr_private_initialize :citationable

  def link_to_citationable
    case citationable
    when Protonym
      link_to(citationable.decorate.link_to_protonym, protonym_path(citationable))
    else
      raise "unknown citationable #{citationable.class.name}"
    end
  end
end
