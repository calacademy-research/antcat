class RemoveSomeEditors < ActiveRecord::Migration
  def up
    User.find_by_email('cgeorgia@biol.uoa.gr').destroy
    User.find_by_email('lgknowland@gmail.com').destroy
    User.find_by_email('whittonr@gmail.com').destroy
    User.find_by_email('ana.mrav@gmail.com').destroy
    User.find_by_email('sossajef@si.edu').destroy
    User.find_by_email('mmprebus@ucdavis.edu').destroy
  end
end
