# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_household_syp_session',
  :secret      => '5e9f4006f790e4c8c2bac43e4697782e97ec0e44b1ad26761fbfcc39c711a5eca503c856b5c6de4e4e2cde50888d0daa336e616d14a7caa6cfd5166d0bd1548f'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
