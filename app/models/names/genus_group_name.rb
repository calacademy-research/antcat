class GenusGroupName < Name
  include Formatters::ItalicsHelper

  def name_html
    italicize name
  end

  def epithet_html
    italicize epithet
  end

  def dagger_html
    italicize super
  end
end
