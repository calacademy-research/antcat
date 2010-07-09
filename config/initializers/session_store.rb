# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_antcat_session',
  :secret      => 'd9a5ab342a38c227eac60986ae5f86b37768d2ddfc62a0fe51556d030ce953b05e1d986a6aadaeb8bdcd96d81e5c8a226c06d73863c247cc887738a71f8342ce'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
