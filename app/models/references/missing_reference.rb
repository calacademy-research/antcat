class MissingReference < Reference
  def keey
    keey_that_makes_the_most_sense
  end

  # This is kind of a lie, but "Mayr, G. 1868a" is better than "[no authors], 1868".
  def keey_without_letters_in_year
    keey_that_makes_the_most_sense
  end

  private

    # Leave out the `#short_citation_year` if the citation contains a year.
    # HACK to make the best of what's in the database.
    def keey_that_makes_the_most_sense
      return citation.html_safe if citation[/\d{4}/]
      "#{citation}, #{short_citation_year}".html_safe
    end
end
