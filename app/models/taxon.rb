class Taxon < ActiveRecord::Base
  set_table_name :taxa
  belongs_to :synonym_of, :class_name => 'Taxon', :foreign_key => :synonym_of_id
  has_one :homonym_replaced, :class_name => 'Taxon', :foreign_key => :homonym_replaced_by_id
  belongs_to :homonym_replaced_by, :class_name => 'Taxon', :foreign_key => :homonym_replaced_by_id
  validates_presence_of :name

  scope :not_homonyms, where("status != ?", 'homonym')

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

  def synonym_of? taxon
    synonym_of == taxon
  end

  def homonym_replaced_by? taxon
    homonym_replaced_by == taxon
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
