class SubgenusName < GenusGroupName

  def self.get_name data
    data[:subgenus_epithet]
  end

  def self.get_parent_name data
    data[:genus] ? data[:genus].name : GenusName.import_data(data)
  end

  def self.make_import_attributes name, data
    parent_name = get_parent_name data
    epithet_html = Formatters::Formatter.italicize name
    {
      epithet:      name,
      epithet_html: epithet_html,
      name:         "#{parent_name} (#{name})",
      name_html:    "#{parent_name.to_html} #{Formatters::Formatter.italicize "(#{name})"}",
    }
  end

end
