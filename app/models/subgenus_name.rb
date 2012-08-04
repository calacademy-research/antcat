class SubgenusName < GenusGroupName

  def self.get_name data
    data[:subgenus_epithet]
  end

  def self.get_parent_name data
    data[:genus] ? data[:genus].name : GenusName.import_data(data)
  end

  def self.make_attributes name, data
    parent_name = get_parent_name data
    html_epithet = Formatters::Formatter.italicize name
    {
      epithet:      name,
      html_epithet: html_epithet,
      name:         "#{parent_name} (#{name})",
      html_name:    "#{parent_name.to_html} #{Formatters::Formatter.italicize "(#{name})"}",
    }
  end

end
