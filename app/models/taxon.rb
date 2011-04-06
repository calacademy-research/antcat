class Taxon < ActiveRecord::Base
  set_table_name :taxa
  belongs_to :synonym_of, :class_name => 'Taxon', :foreign_key => :synonym_of_id
  belongs_to :homonym_resolved_to, :class_name => 'Taxon', :foreign_key => :homonym_resolved_to_id
  validates_presence_of :name

  def unavailable?;     status == 'unavailable' end
  def available?;       !unavailable? end
  def invalid?;         status != 'valid' end
  def unidentifiable?;  status == 'unidentifiable' end
  def synonym?;         status == 'synonym' end
  def homonym?;         status == 'homonym' end

  def children
    raise NotImplementedError
  end

  def current_valid_name
    target = self
    target = target.synonym_of while target.synonym_of
    target.name
  end

  def self.find_name name, search_type = 'matching'
    case search_type
    when 'matching'
      Taxon.all :conditions => ['name = ?', name]
    when 'beginning with'
      Taxon.all :conditions => ['name LIKE ?', name + '%']
    when 'containing'
      Taxon.all :conditions => ['name LIKE ?', '%' + name + '%']
    end
  end

end
