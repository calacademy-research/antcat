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

  def rank
    self.class.to_s.downcase
  end

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
      conditions = ['name = ? AND type IN (?)', name, ['Subfamily', 'Genus', 'Species']]
    when 'beginning with'
      conditions = ['name LIKE ? AND type IN (?)', name + '%', ['Subfamily', 'Genus', 'Species']]
    when 'containing'
      conditions = ['name LIKE ? AND type IN (?)', '%' + name + '%', ['Subfamily', 'Genus', 'Species']]
    end
    Taxon.all :conditions => conditions
  end

end
