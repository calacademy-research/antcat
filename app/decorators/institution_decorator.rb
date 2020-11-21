# frozen_string_literal: true

class InstitutionDecorator < Draper::Decorator
  delegate :grscicoll_identifier

  def link_to_grscicoll
    return unless grscicoll_url

    h.external_link_to 'GRSciColl', grscicoll_url
  end

  def grscicoll_url
    return unless grscicoll_identifier

    @_grscicoll_url ||= "#{Institution::GRSCICOLL_BASE_URL}#{grscicoll_identifier}"
  end
end
