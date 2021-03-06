require 'tree'

class CollectionsController < ApplicationController
  
  load_and_authorize_resource
   
  # GET /collections
  # GET /collections.xml

  def index
    @collections = Collection.all

    Collection.all.sort_by{ |c| c.parent_collections.length }.each do |c|
      # if collection has no parents, add it directly to tree
      root_node = Tree::TreeNode.new("ROOT")

      if c.parent_collections.length == 0
        root_node << Tree::TreeNode.new(c.id.to_s)
      else
      #otherwise, find where to add, and add it there
      # looping through the parents of this collection
        c.parent_collections.each do |parent|
          root_node.each do |node| 
            node << Tree::TreeNode.new(c.id.to_s) if node.name == parent.id.to_s
          end
        end
      end
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @collections }
      format.js { 
        @collections = params[:term].length == 1 ? Collection.where(:name => /^#{params[:term]}/i) : Collection.where(:name => /#{params[:term]}/i)
        render :json => @collections.map {|x| {"label" => x.name, "id" => x._id, "value"=> x.name}} 
      }
    end
  end


  # GET /collections/1
  # GET /collections/1.xml
  def show
    @collection = Collection.find(params[:id])

    respond_to do |format|
      format.js
      format.html # show.html.erb
      format.xml  { render :xml => @collection }
    end
  end

  # GET /collections/new
  # GET /collections/new.xml
  def new
    @collection = Collection.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @collection }
    end
  end

  # GET /collections/1/edit
  def edit
    @collection = Collection.find(params[:id])
  end

  # POST /collections
  # POST /collections.xml
  def create
    @collection = Collection.new(params[:collection])

    respond_to do |format|
      if @collection.save && @collection.update_relations(params[:collection])
        format.html { redirect_to(@collection, :notice => 'Collection was successfully created.') }
        format.xml  { render :xml => @collection, :status => :created, :location => @collection }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @collection.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /collections/1
  # PUT /collections/1.xml
  def update
    @collection = Collection.find(params[:id])

    respond_to do |format|
      if @collection.update_attributes(params[:collection])
        format.html { redirect_to(@collection, :notice => 'Collection was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @collection.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /collections/1
  # DELETE /collections/1.xml
  def destroy
    @collection = Collection.find(params[:id])
    @collection.destroy

    respond_to do |format|
      format.html { redirect_to(collections_url) }
      format.xml  { head :ok }
    end
  end

end