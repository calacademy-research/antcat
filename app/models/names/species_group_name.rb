class SpeciesGroupName < Name
  include UndoTracker

  has_paper_trail meta: { change_id: :get_current_change_id }

  def genus_epithet
    words[0]
  end

  def species_epithet
    words[1]
  end

  def dagger_html
    italicize super
  end
end
