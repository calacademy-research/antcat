class GenusName < GenusGroupName

  def self.get_name data
    data[:genus_name]
  end

  def self.make_attributes name, data
    html_name = '<i>'.html_safe + name + '</i>'.html_safe
    {
      name:         name,
      html_name:    html_name,
      epithet:      name,
      html_epithet: html_name,
    }
  end

end
