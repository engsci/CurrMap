class TermsController < ApplicationController

  # GET /terms
  def index
    @yggdrasil = Term.root

    respond_to do |format|
      format.html # index.html.haml
    end
  end

  def show
    @term = Term.find(params[:id].to_i)
    respond_to do |format|
      format.html
    end
  end

  # GET /terms/new
  def new
    @term = Term.new
    respond_to do |format|
      format.html
    end
  end

  # POST /terms
  def create
    if params[:term][:supertopics]
      params[:term][:name] = [params[:term].delete(:supertopics),
                              params[:term][:name]].join('/')
    end
    @term = Term.new(params[:term])
    respond_to do |format|
      if @term.save
        format.html { redirect_to terms_url, :notice => 'Term successfully added' }
      else
        format.html { render :action => 'new' }
      end
    end
  end

  def edit
    @term = Term.find(params[:id].to_i)
    respond_to do |format|
      format.html
    end
  end

  def update
  end

  def destroy
  end

end
