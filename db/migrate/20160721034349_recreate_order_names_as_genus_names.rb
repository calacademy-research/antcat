# See https://github.com/calacademy-research/antcat/issues/155
#
# TL;DR: we're recreating three `OrderName`s (a deleted model) as
# `GenusName`s to make editing these work again:
# http://localhost:3000/taxa/429240/edit # Camponotini
# http://localhost:3000/taxa/429869/edit # Crematogastrini
# http://localhost:3000/taxa/461837/edit # Pogonomyrmecini

class RecreateOrderNamesAsGenusNames < ActiveRecord::Migration
  def up
    fix_camponotini = GenusName.new name: "Florida",
      name_html: "Florida", epithet: "Florida",
      epithet_html: "Florida", epithets: nil,
      protonym_html: "Florida", gender: nil,
      auto_generated: false, origin: nil,
      nonconforming_name: nil
    fix_camponotini.id = 135980
    fix_camponotini.save!

    fix_camponotini.created_at = "2012-09-12 02:18:34"
    fix_camponotini.updated_at = "2012-09-12 02:18:34"
    fix_camponotini.save!

    ###

    fix_crematogastrini = GenusName.new name: "Guinea",
      name_html: "Guinea", epithet: "Guinea",
      epithet_html: "Guinea", epithets: nil,
      protonym_html: "Guinea", gender: nil,
      auto_generated: false, origin: nil,
      nonconforming_name: nil
    fix_crematogastrini.id = 134939
    fix_crematogastrini.save!

    fix_crematogastrini.created_at = "2012-09-12 02:17:44"
    fix_crematogastrini.updated_at = "2012-09-12 02:17:44"
    fix_crematogastrini.save!

    ###

    fix_pogonomyrmecini = GenusName.new name: "California",
      name_html: "California", epithet: "California",
      epithet_html: "California", epithets: nil,
      protonym_html: "California", gender: nil,
      auto_generated: false, origin: nil,
      nonconforming_name: nil
    fix_pogonomyrmecini.id = 134077
    fix_pogonomyrmecini.save!

    fix_pogonomyrmecini.created_at = "2012-09-12 02:17:07"
    fix_pogonomyrmecini.updated_at = "2012-09-12 02:17:07"
    fix_pogonomyrmecini.save!
  end

  def down
    ids = [135980, 134939, 134077]
    ids.each do |id|
      if GenusName.exists? id
        GenusName.find(id).destroy
      end
    end
  end
end
