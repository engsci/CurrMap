class ResourcesController < ApplicationController
  
  load_and_authorize_resource
  
  # GET /resources
  # GET /resources.xml
  def index
    @resources = Resource.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @resources }
      format.js { 
        render :json => Resource.search_as_you_type(params[:term]) 
        }
    end
  end

  # GET /resources/1
  # GET /resources/1.xml
  def show
    @resource = Resource.find(params[:id])
        
    respond_to do |format|
      format.js 
      format.html # show.html.erb
      format.xml  { render :xml => @resource }
    end
  end

  # GET /resources/new
  # GET /resources/new.xml
  def new
    @resource = Textbook.new
    @resource.authors << Author.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @resource }
    end
  end

  # GET /resources/1/edit
  def edit
    @resource = Resource.find(params[:id])
    
    if @resource.class == Textbook
      @resource.authors << Author.new
    end
  end

  # POST /resources
  # POST /resources.xml
  def create
    if params[:resource]
      @resource = Resource.new(params[:resource])
    elsif params[:textbook]
      @resource = Textbook.new(params[:textbook])
    end

    respond_to do |format|
      if @resource.save && @resource.update_relations(params[@resource.class.to_s.underscore.to_sym])
        format.html { redirect_to(@resource, :notice => 'Resource was successfully created.') }
        format.xml  { render :xml => @resource, :status => :created, :location => @resource }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @resource.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /resources/1
  # PUT /resources/1.xml
  def update
    @resource = Resource.find(params[:id])

    respond_to do |format|
      if @resource.update_attributes(params[:resource] || params[:textbook])
        format.html { redirect_to(@resource, :notice => 'Resource was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @resource.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /resources/1
  # DELETE /resources/1.xml
  def destroy
    @resource = Resource.find(params[:id])
    @resource.destroy

    respond_to do |format|
      format.html { redirect_to(resources_url) }
      format.xml  { head :ok }
    end
  end
  
  
 
  
end
