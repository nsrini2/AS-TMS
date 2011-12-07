require 'delayed_job'

# Doesn't work with Rails 2.1.1
# config.after_initialize do
#   Delayed::Worker.guess_backend
# end