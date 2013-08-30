class Accounts < ActiveRecord::Migration
  def up
    User.find_by_email('mlborowiec@ucdavis.edu').update_attributes! can_edit_catalog: true, can_approve_changes: true
    User.find_by_email('mgbranstetter@ucdavis.edu').update_attributes! can_edit_catalog: true, can_approve_changes: true
    User.find_by_email('jacklongino@gmail.com').update_attributes! can_edit_catalog: true, can_approve_changes: true
    User.find_by_email('psward@ucdavis.edu').update_attributes! can_edit_catalog: true, can_approve_changes: true

    User.invite! email: 'bonnieblaimer@gmail.com', can_edit_catalog: true, can_approve_changes: true
    User.invite! email: 'rsmfeitosa@gmail.com', name: 'Rodrigo Feitosa', can_edit_catalog: true, can_approve_changes: true
    User.invite! email: 'georgf81@gmail.com', name: 'Georg Fischer', can_edit_catalog: true, can_approve_changes: true
    User.invite! email: 'fhitagarcia@gmail.com', name: 'Paco Hita-Garcia', can_edit_catalog: true, can_approve_changes: true
    User.invite! email: 'e.sarnat@gmail.com', name: 'Eli Sarnat', can_edit_catalog: true, can_approve_changes: true
    User.invite! email: 'soshattuck@gmail.com', name: 'Steve Shattuck', can_edit_catalog: true, can_approve_changes: true
    User.invite! email: 'myoshimura@ant-database.org', name: 'Masahi Yoshimura', can_edit_catalog: true, can_approve_changes: true
  end
end
