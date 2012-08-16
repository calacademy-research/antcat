class GenusName < GenusGroupName

  def self.get_name data
    data[:genus_name]
  end

  def self.make_import_attributes name, data
    name_html = Formatters::Formatter.italicize name
    {
      name:         name,
      name_html:    name_html,
      epithet:      name,
      epithet_html: name_html,
    }
  end

end
