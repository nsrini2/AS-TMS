# Be sure to restart your server when you modify this file.

# AgentstreamDe::Application.config.session_store :cookie_store, :key => '_agentstream_de_session'

AgentstreamDe::Application.config.session_store :cookie_store, {
    :key         => '_agentstream_session',
    :secret      => 'e5c2796a228da278ecc23de8541b6082d83188ee4836d1ab7397ed3767f7fe27f599197356bd56653f08ea02d31aa24b2faeddc46432ee942a36262156857315'
  }

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# AgentstreamDe::Application.config.session_store :active_record_store
