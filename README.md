Added smtp_tls library (vendor/plugins/action_mailer_tls plugin) to make application work with gmail.
This was needed even though the AgentStream app uses Ruby version 1.8.7 which is supposed to have smtp support built in.

Modified environment.rb file to include smtp settings for gmail account
