class TermsController < ApplicationController

  # GET /terms
  def index
    @yggdrasil = Term.root

    respond_to do |format|
      format.html # index.html.haml
    end
  end

  def show
  end

  # GET /terms/new
  def new
    @term = Term.new({})
    respond_to do |format|
      format.html
    end
  end

  # POST /terms
  def create
    @term = Term.new(params[:term])
    respond_to do |format|
      if @term.save
        format.html { redirect_to @term, :notice => 'Term successfully added' }
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
