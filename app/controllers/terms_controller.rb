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
    @term = Term.find(params[:id].to_i)

    # Update synoyms
    synonyms = params[:term][:synonyms].split(/\s*,\s*/)
    if synonyms != @term.synonyms
      begin
        add_synonym @term, synonyms - @term.synonyms
      rescue ConnectionError
        respond_to {|f|
          f.html { redirect_to edit_term_url(@term) }
        }
        return
      end
    end

    respond_to do |format|
      format.html do
        redirect_to term_url(@term), :notice => 'Term successfully updated'
      end
    end
  end

  def destroy
  end

  def search
    words = params[:term].split(/\s*,\s*/)
    phrase = words.last
    remainder = words.slice(0, words.length-1).join(', ')
    respond_to do |format|
      format.json { render :json => Term.search(phrase).map{|word|
        "#{remainder}, #{word}"}.to_json }
    end
  end

  protected

  def add_synonym term, words
    words.each {|word| Term.add_synonym term.name, word}
  end

end
