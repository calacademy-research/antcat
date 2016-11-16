module DatabaseScripts::Renderers::Plaintext
  def plaintext text
    brify_newlines text
  end

  private
    # "\n" --> "<br>"
    def brify_newlines text
      "#{text.gsub(/\n+/, "<br>")}".html_safe
    end
end
