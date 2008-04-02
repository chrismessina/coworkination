ActionController::Routing::Routes.draw do |map|
  
  # homepage
  map.connect '', :controller => "places", :action => "homepage"
  
  map.resources :places,  
                :collection => {:search => :get}
  map.resources :people,  :collection => {:search => :get}
  map.resources :events,  :collection => {:search => :get}
  map.resources :openids, :member => { :complete => :get}
  
  map.open_id_complete  'session', 
                        :controller => "session", 
                        :action => "create", :requirements => { :method => :get }
  map.resource :session
  map.logout '/logout', :controller => 'session', :action => 'destroy'

end
