# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_live_qa_session',
  :secret      => '1ba0553a0179ea7495ad6bbaea05849d69a4ae6c9584a7a3d8483006451fe6e91eb37cc86fa9ec16d5c2d690b081d654253e5c7df72c362559043f81f9c62a06'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
