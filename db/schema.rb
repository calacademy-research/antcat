# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100811194625) do

  create_table "refs", :force => true do |t|
    t.string   "authors"
    t.string   "year"
    t.string   "title"
    t.string   "citation"
    t.string   "public_notes"
    t.string   "possess"
    t.string   "date"
    t.datetime "created_at"
    t.string   "cite_code"
    t.datetime "updated_at"
    t.string   "journal_title"
    t.string   "series"
    t.string   "volume"
    t.string   "issue"
    t.string   "start_page"
    t.string   "end_page"
    t.string   "place"
    t.string   "publisher"
    t.string   "pagination"
    t.string   "kind"
    t.integer  "numeric_year"
    t.string   "editor_notes"
    t.string   "taxonomic_notes"
  end

end
