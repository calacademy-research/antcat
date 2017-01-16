module DatabaseScripts::Renderers::Plaintext
  delegate :simple_format, to: :text_helper

  def plaintext text
    simple_format text
  end

  private
    # TODO improve? Not sure how to.
    def text_helper
      TextHelper.instance
    end

    class TextHelper
      include Singleton
      include ::ActionView::Helpers::TextHelper
    end
end
