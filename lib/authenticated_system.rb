module AuthenticatedSystem
  protected
    # Returns true or false if the user is logged in.
    # Preloads @current_person with the user model if they're logged in.
    def logged_in?
      current_person != :false
    end
    
    # Accesses the current person from the session.  Set it to :false if login fails
    # so that future calls do not hit the database.
    def current_person
      @current_user ||= (login_from_session || login_from_basic_auth || login_from_cookie || :false)
    end
    
    # Store the given person in the session.
    def current_person=(new_person)
      session[:person] = (new_person.nil? || new_person.is_a?(Symbol)) ? nil : new_person.id
      @current_person = new_person
    end
    
    # Check if the person is authorized
    #
    # Override this method in your controllers if you want to restrict access
    # to only a few actions or if you want to check if the person
    # has the correct rights.
    #
    # Example:
    #
    #  # only allow nonbobs
    #  def authorized?
    #    current_person.login != "bob"
    #  end
    def authorized?
      logged_in?
    end

    # Filter method to enforce a login requirement.
    #
    # To require logins for all actions, use this in your controllers:
    #
    #   before_filter :login_required
    #
    # To require logins for specific actions, use this in your controllers:
    #
    #   before_filter :login_required, :only => [ :edit, :update ]
    #
    # To skip this in a subclassed controller:
    #
    #   skip_before_filter :login_required
    #
    def login_required
      authorized? || access_denied
    end

    # Redirect as appropriate when an access request fails.
    #
    # The default action is to redirect to the login screen.
    #
    # Override this method in your controllers if you want to have special
    # behavior in case the person is not authorized
    # to access the requested action.  For example, a popup window might
    # simply close itself.
    def access_denied
      respond_to do |accepts|
        accepts.html do
          store_location
          redirect_to :controller => '/sessions', :action => 'new'
        end
        accepts.xml do
          headers["Status"]           = "Unauthorized"
          headers["WWW-Authenticate"] = %(Basic realm="Web Password")
          render :text => "Could't authenticate you", :status => '401 Unauthorized'
        end
      end
      false
    end  
    
    # Store the URI of the current request in the session.
    #
    # We can return to this location by calling #redirect_back_or_default.
    def store_location
      session[:return_to] = request.request_uri
    end
    
    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default.
    def redirect_back_or_default(default)
      session[:return_to] ? redirect_to_url(session[:return_to]) : redirect_to(default)
      session[:return_to] = nil
    end
    
    # Inclusion hook to make #current_person and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_person, :logged_in?
    end

    # Called from #current_user.  First attempt to login by the user id stored in the session.
    def login_from_session
      self.current_person = Person.find_by_id(session[:person]) if session[:person]
    end

    # Called from #current_user.  Now, attempt to login by basic authentication information.
    def login_from_basic_auth
      username, passwd = get_auth_data
      self.current_person = Person.authenticate(username, passwd) if username && passwd
    end

    # Called from #current_user.  Finaly, attempt to login by an expiring token in the cookie.
    def login_from_cookie      
      person = cookies[:auth_token] && Person.find_by_remember_token(cookies[:auth_token])
      if person && person.remember_token?
        person.remember_me
        cookies[:auth_token] = { :value => person.remember_token, :expires => person.remember_token_expires_at }
        self.current_person = person
      end
    end

  private
    @@http_auth_headers = %w(X-HTTP_AUTHORIZATION HTTP_AUTHORIZATION Authorization)
    # gets BASIC auth info
    def get_auth_data
      auth_key  = @@http_auth_headers.detect { |h| request.env.has_key?(h) }
      auth_data = request.env[auth_key].to_s.split unless auth_key.blank?
      return auth_data && auth_data[0] == 'Basic' ? Base64.decode64(auth_data[1]).split(':')[0..1] : [nil, nil] 
    end
end
