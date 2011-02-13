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
    @term = Term.new(params[:term])
    if @term.supertopcs
      @term.supertopics = [@term.supertopics] unless @term.supertopics.is_a? Array
    else
      @term.supertopics = []
    end
    respond_to do |format|
      if @term.save
        format.html { redirect_to terms_url, :notice => 'Term successfully added' }
      else
        format.html { render :action => 'new' }
      end
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

end
