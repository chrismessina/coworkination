# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  
  htpasswd :user => ADMIN_USERNAME, :pass => ADMIN_PASSWORD if RAILS_ENV == 'staging'  
  
  include AuthenticatedSystem
  before_filter :login_from_cookie
  
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_coworkination_session_id'
  
  
end
