class GenusGroupName < Name
  def epithet_to_html
    italicize epithet
  end

  def dagger_html
    italicize super
  end
end
