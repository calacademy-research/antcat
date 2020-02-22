module References
  class FormatItalics
    include Service

    def initialize content
      @content = content
    end

    def call
      return unless content
      raise "Can't call format_italics on an unsafe string" unless content.html_safe?

      content.gsub(/\*(.*?)\*/, '<i>\1</i>').html_safe
    end

    private

      attr_reader :content
  end
end
