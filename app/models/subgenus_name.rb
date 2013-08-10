# coding: UTF-8
class SubgenusName < GenusGroupName
  extend Formatters::Formatter

  def self.get_name data
    data[:subgenus_epithet]
  end

  def self.get_parent_name data
    if data[:genus]
      data[:genus].name
    elsif data[:genus_name] && data[:genus_name].kind_of?(Name)
      data[:genus_name]
    else
      GenusName.import_data data
    end
  end

  def self.make_import_attributes name, data
    parent_name = get_parent_name data
    epithet_html = italicize name
    name_html = "#{parent_name.to_html} #{italicize "(#{name})"}"
    {
      epithet:      name,
      epithet_html: epithet_html,
      name:         "#{parent_name} (#{name})",
      name_html:    name_html,
      protonym_html:name_html,
    }
  end

end
