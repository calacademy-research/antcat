class MergeUpdatedBoltonReferences < ActiveRecord::Migration
  def up
    # merge two sets of Bolton references which couldn't be
    # matched automatically because two out of author, year
    # title changed

    old = Bolton::Reference.find 959
    raise unless old.title =~ /Revision of the ant genus/
    neww = Bolton::Reference.find 4548
    raise unless neww.title =~ /Revision of the ant genus/
    old.title = neww.title
    old.citation_year = neww.citation_year
    old.authors = neww.authors
    old.original = neww.original
    old.save!
    neww.delete

    old = Bolton::Reference.find 3793
    raise unless old.authors =~ /Zolessi/
    neww = Bolton::Reference.find 4620
    raise unless neww.authors =~ /Zolessi/
    old.title = neww.title
    old.citation_year = neww.citation_year
    old.authors = neww.authors
    old.original = neww.original
    old.save!
    neww.delete

  end

  def down
  end
end
