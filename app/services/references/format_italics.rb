# frozen_string_literal: true

module References
  class FormatItalics
    include Service

    attr_private_initialize :content

    def call
      return unless content
      raise "Can't call format_italics on an unsafe string" unless content.html_safe?

      content.gsub(/\*(.*?)\*/, '<i>\1</i>').html_safe
    end
  end
end
