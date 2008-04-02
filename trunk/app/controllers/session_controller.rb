# This controller handles the login/logout function of the site.  
class SessionController < ApplicationController
  def new
  end

  def create
    if using_open_id? || !params[:wordpress].blank? || !params[:livejournal].blank? || !params[:aim_screenname].blank?
      params[:openid_url] = "http://#{params[:wordpress]}.wordpress.com" unless params[:wordpress].blank?
      params[:openid_url] = "http://#{params[:livejournal]}.livejournal.com" unless params[:livejournal].blank?
      params[:openid_url] = "http://openid.aol.com/#{params[:aim_screenname]}" unless params[:aim_screenname].blank?
      open_id_authentication
    else
      redirect_to :action => 'new'
    end
  end
  
  def destroy
    self.current_person.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end

  protected
  
    # TODO: get rif of password authentication
    def password_authentication(login, password)
      self.current_person = Person.authenticate(login, password)
      if logged_in?
        if params[:remember_me] == "1"
          self.current_person.remember_me
          cookies[:auth_token] = { :value => self.current_person.remember_token , :expires => self.current_person.remember_token_expires_at }
        end
        successful_login
      else
        failed_login('Invalid login or password')
      end
    end

    def open_id_authentication
      # Pass optional :required and :optional keys to specify what sreg fields you want.
      # Be sure to yield registration, a third argument in the #authenticate_with_open_id block.
      authenticate_with_open_id(params[:openid_url], :required => :fullname, :optional => :nickname) do |result, identity_url, registration|
        if result.successful?
          if !@user = Person.find_by_identity_url(identity_url)
            names = registration['fullname'].split
            family_name = names.pop
            given_name = names.join(' ')
            @user = Person.new( :identity_url => identity_url,
                                :given_name => given_name,
                                :family_name => family_name,
                                :nickname => registration['nickname'])
            assign_registration_attributes!(registration)
          end
          self.current_person = @user
          successful_login
        else
          failed_login(result.message || "Sorry could not log in with identity URL: #{identity_url}")
        end
      end
    end

    # registration is a hash containing the valid sreg keys given above
    # use this to map them to fields of your user model
    def assign_registration_attributes!(registration)
      { :login => 'nickname', :email => 'email' }.each do |model_attribute, registration_attribute|
        unless registration[registration_attribute].blank?
          @user.send("#{model_attribute}=", registration[registration_attribute])
        end
      end
      @user.save!
    end

  private
  
    def successful_login
      redirect_back_or_default('/')
      flash[:notice] = "Logged in successfully"
    end

    def failed_login(message)
      flash.now[:error] = message
      render :action => 'new'
    end

end
