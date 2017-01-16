class GenusName < GenusGroupName
  def genus_name
    words[0]
  end

  def genus_epithet
    genus_name
  end
end
