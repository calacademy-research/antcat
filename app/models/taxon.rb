class Taxon < ActiveRecord::Base
  set_table_name :taxa
  belongs_to :synonym_of, :class_name => 'Taxon', :foreign_key => :synonym_of_id

  def unavailable?;     status == 'unavailable' end
  def available?;       !unavailable? end
  def invalid?;         !status.blank? end
  def unidentifiable?;  status == 'unidentifiable' end
  def synonym?;         status == 'synonym' end

  def children
    raise NotImplementedError
  end

end
