class MissingReference < Reference
  validates :citation_year, format: { with: /\A\d{4}[a-z]?\z/ }

  def keey
    keey_that_makes_the_most_sense
  end

  # This is kind of a lie, but "Mayr, G. 1868a" is better than "[no authors], 1868".
  def keey_without_letters_in_year
    keey_that_makes_the_most_sense
  end

  private

    # Leave out the `#short_citation_year` if the citation contains a year.
    # HACK: To make the best of what's in the database.
    def keey_that_makes_the_most_sense
      return citation_and_warning if citation[/\d{4}/]
      "#{citation_and_warning}, #{citation_year || '[no year]'}".html_safe
    end

    def citation_and_warning
      '<span class="bold-warning">[missing reference]</span> '.html_safe + citation.html_safe
    end
end
