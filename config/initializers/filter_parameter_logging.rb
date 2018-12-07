# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters +=
  [:password, :tenancy_ref, :email_address,
   'first name', 'last name', 'full name']
