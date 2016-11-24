class GenusName < GenusGroupName
  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }

  def genus_name
    words[0]
  end

  def genus_epithet
    genus_name
  end
end
