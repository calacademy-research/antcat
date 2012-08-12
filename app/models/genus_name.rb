class GenusName < GenusGroupName

  def self.get_name data
    data[:genus_name]
  end

  def self.make_import_attributes name, data
    html_name = Formatters::Formatter.italicize name
    {
      name:         name,
      html_name:    html_name,
      epithet:      name,
      html_epithet: html_name,
    }
  end

end
