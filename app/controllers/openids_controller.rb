# TODO: replace authentication with Acts as Authentication + OpenID
# http://www.bencurtis.com/archives/2007/03/rails-openid-and-acts-as-authenticated/

require_gem 'ruby-openid'

class OpenidsController < ApplicationController

  # GET
  # show a form requesting the user's OpenID
  def new
  end

  # GET
  # begin the OpenID verification process
  def create
    openid_url = params[:openid_url]
    response = openid_consumer.begin openid_url

    if response.status == OpenID::SUCCESS
      response.add_extension_arg('sreg','required','email')
      # TODO ask for given, family names from OpenID provider here      
      redirect_url = response.redirect_url(home_url, complete_openid_url)
      redirect_to redirect_url
      return
    end

    flash[:error] = "Couldn't find an OpenID for that URL"
    render :action => :new  
  end

  # GET
  # complete the OpenID verification process
  def complete
    response = openid_consumer.complete params

    if response.status == OpenID::SUCCESS
      session[:openid] = response.identity_url
      # TODO: grab user from db based on OpenID url
      session[:user] = Person.find_by_openid_url(response.identity_url)
      # the user is now logged in with OpenID!
      @registration_info = response.extension_response('sreg') # <= { 'name' => 'Dan Webb', etc... }
      redirect_to home_url
      return
    end

    flash[:error] = 'Could not log on with your OpenID'
    redirect_to new_openid_url  
  end

  protected

    def openid_consumer
      @openid_consumer ||= OpenID::Consumer.new(session,      
        OpenID::FilesystemStore.new("#{RAILS_ROOT}/tmp/openid"))
    end

end