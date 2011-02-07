class Taxon < ActiveRecord::Base
  set_table_name :taxa

  def unavailable?;     status == 'unavailable' end
  def available?;       !unavailable? end
  def invalid?;         !status.blank? end
  def unidentifiable?;  status == 'unidentifiable' end
  def synonym?;         status == 'synonym' end

  def children
    raise NotImplementedError
  end

end
