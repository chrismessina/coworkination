class PeopleController < ApplicationController
  before_filter :restrict_access_to_owner, :only => [:edit, :update, :activate]
  
  def create
    @person = Person.new(params[:person])
    @person.save!
    self.current_person = @person
    redirect_back_or_default('/')
    flash[:notice] = "Thanks for signing up!"
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end
  
  def edit
  end
  
  def update
    if @person.update_attributes(params[:person])
      flash[:notice] = "You're profile has been updated"
    end
    render :action => 'edit'
  end

  def activate
    self.current_person = Person.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_person.activated?
      current_person.activate
      flash[:notice] = "Signup complete!"
    end
    redirect_back_or_default('/')
  end
  
protected 

  def restrict_access_to_owner
    @person = Person.find(params[:id])
    if @person.id != current_person.id
      redirect_to '/' and return false
    end
  rescue
    redirect_to '/' and return false
  end  
  
end