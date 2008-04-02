class PlacesController < ApplicationController

  # TODO: require admin login for edit, update (for moderation purposes)
  
  # include microformat helper - http://blog.labnotes.org/2006/08/25/microformats-helper-for-ruby-on-rails/
  helper :microformat

  # GET /
  def homepage
    @places = Place.find(:all)    
    map
  end
  
  # GET /places;search/:search_term
  def search
    query = params[:q]
    @places = Place.find_by_contents(query)      
    begin
      @places.concat(Place.find(:all, :origin => query, :within => 15))
    rescue 
      logger.error("Query could not be geocoded #{query}") 
    end
    if @places
      origin  = [@places.first.lat, @places.first.lng]
      zoom    = 10
    end
    map(origin, zoom)
  end
  
  # GET /places
  # GET /places.xml
  def index
    # TODO: move map to a fixture
    @map = GMap.new("map_div_id")  
    @map.control_init(:large_map => true, :map_type => true)  
    @map.center_zoom_init([37.759722,-100.018333], 4)  
    
    # load markers
    @places = Place.find(:all)
    @places.each do |place|
      marker = GMarker.new("#{place.street_address}, #{place.postal_code}",   
        :title => place.org, :info_window => "<h1><a href='#{place_path(place)}'>#{place.org}</a></h1><img alt='#{place.org} photo' height='50' src='#{place.photo}' width='50' style='float:left; margin-right: 1em;' />#{rand(10)} members there right now")
      @map.overlay_init(marker)    
    end    
    
    @new_places = Place.find(:all, :limit => 5)
    
    @active_places = Place.find(:all, :limit => 5)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @places }
    end
  end
  
  # GET /places/1
  # GET /places/1.xml
  def show
    @place = Place.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @place }
    end
  end

  # GET /places/new
  # GET /places/new.xml
  def new
    @place = Place.new
    respond_to do |format|
      format.html { render(:layout => false) }
      format.xml  { render :xml => @place }
    end
  end

  # GET /places/1;edit
  def edit
    @place = Place.find(params[:id])
  end

  # POST /places
  # POST /places.xml
  def create
    @place = Place.new(params[:place])
    
    respond_to do |format|
      if @place.save
        flash[:notice] = 'Place was successfully created.'
        format.html { redirect_to place_url(@place) }
        format.xml  { render :xml => @place, :status => :created, :location => place_url(@place) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @place.errors }
      end
    end
  end

  # PUT /places/1
  # PUT /places/1.xml
  def update
    @place = Place.find(params[:id])

    respond_to do |format|
      if @place.update_attributes(params[:place])
        flash[:notice] = 'Place was successfully updated.'
        format.html { redirect_to place_url(@place) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @place.errors }
      end
    end
  end

  # DELETE /places/1
  # DELETE /places/1.xml
  def destroy
    @place = Place.find(params[:id])
    @place.destroy

    respond_to do |format|
      format.html { redirect_to places_url }
      format.xml  { head :ok }
    end
  end

protected

  def postal_code? (subject)
    /\d{5}(-\d{4})?|[ABCEGHJKLMNPRSTVXY]\d[A-Z] \d[A-Z]\d|[A-Z]{1,2}\d[A-Z\d]? \d[ABD-HJLNP-UW-Z]{2}/.match(subject)
  end
  
  def map(origin=[37.759722,-100.018333], zoom=4)
    @map = GMap.new("map_div_id")  
    @map.control_init(:large_map => true, :map_type => true)  
    @map.center_zoom_init(origin, zoom)  
    
    # load markers
    @places.each do |place|
      marker = GMarker.new("#{place.street_address}, #{place.postal_code}",   
        :title => place.org, 
        :info_window => "<h1><a href='#{place_path(place)}'>#{place.org}</a></h1><img alt='#{place.org} photo' height='50' src='#{place.photo}' width='50' style='float:left; margin-right: 1em;' />#{rand(10)} members there right now"# ,
        #         :icon => GIcon.new( :image => "http://www.juixe.com/techknow/wp-content/plugins/social_bookmarks/rojo.png", 
        #                             :icon_size => GSize.new(15,15),
        #                             :icon_anchor => GPoint.new(7,7),
        #                             :info_window_anchor => GPoint.new(9,2)
        #                           )
        )
      @map.overlay_init(marker)          
    end    
  end
  
end
