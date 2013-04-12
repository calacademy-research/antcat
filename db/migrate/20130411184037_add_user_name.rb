# coding: UTF-8
class AddUserName < ActiveRecord::Migration
  def up
    add_column :users, :name, :string rescue nil

    set_name 'mark@mwilden.com',          'Mark Wilden'
    set_name 'sblum@calacademy.org',      'Stan Blum'
    set_name 'bfisher@calacademy.org',    'Brian Fisher'
    set_name 'psward@ucdavis.edu',        'Phil Ward'
    set_name 'mlborowiec@ucdavis.edu',    'Marek Borowiec'
    set_name 'agosti@amnh.org',           'Donat Agosti'
    set_name 'lgknowland@gmail.com',      'Luke Knowland'
    set_name 'deepreef@bishopmuseum.org', 'Rich Powell'
    set_name 'mgbranstetter@ucdavis.edu', 'Michael Branstetter'
    set_name 'bbblaimer@ucdavis.edu',     'Bonnie Blaimer'
    set_name 'mmprebus@ucdavis.edu',      'Matthew Prebus'
    set_name 'flaviaesteves@gmail.com',   'Flávia Estevez'
    set_name 'ana.mrav@gmail.com',        'Ana Jesovnik'
    set_name 'sossajef@si.edu',           'Jeffrey Sosa-Calvo'
    set_name 'ndemik@yahoo.com',          'Eli Sarnat'
    set_name 'zeroben@gmail.com',         'Benoit Guénard'
    set_name 'jacklongino@gmail.com',     'Jack Longino'
    set_name 'zelieberman@gmail.com',     'Zach Lieberman'
    set_name 'cgeorgia@biol.uoa.gr',      'Christos Georgiadis'
  end

  def set_name email, name
    User.find_by_email(email).update_attributes! name: name rescue nil
  end

  def down
    remove_column :users, :name
  end
end
