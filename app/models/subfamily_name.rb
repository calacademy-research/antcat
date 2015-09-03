# coding: UTF-8
class SubfamilyName < FamilyOrSubfamilyName
  has_paper_trail meta: {change_id: :get_current_change_id}
  include UndoTracker


  def self.parse_words words
    return unless words.size == 1
    create! make_import_attributes words[0]
  end

  def self.get_name data
    data[:subfamily_name]
  end

  def self.make_import_attributes name, _ = nil
    name_html = name
    {
      name:         name,
      name_html:    name_html,
      epithet:      name,
      epithet_html: name_html,
    }
  end

end
