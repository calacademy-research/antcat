class FixNomenNudumName < ActiveRecord::Migration
  def up
    Taxt.replace /{nam 137004}/, '<i>Nomen nudum</i>'
  end
end
