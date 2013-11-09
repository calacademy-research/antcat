class AddChristos < ActiveRecord::Migration
  def up
    User.destroy_all email: 'cgeorgia@biol.uoa.gr'
    User.create! email:  'cgeorgia@biol.uoa.gr', name: 'Christos Georgiadis', can_edit_catalog: true, password: 'secret'
  end
end
