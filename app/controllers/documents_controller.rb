class DocumentsController < ApplicationController
  def index
    @documents = Document.all
  end
  
  def show
    @document = Document.find(params[:id])
  end
  
  def new
    @document = Document.new
  end
  
  def create
    @document = Document.new(params[:document])
    
    @parent = params[:model].constantize.find(params[:id])
    
    respond_to do |format|
      if @document.save && @parent.documents << @document
        format.html{ redirect_to(documents_path, :notice => 'Document succesfully created.') }
        format.js
      else
        format.html { render :action => "new" }
        format.js
      end
    end
  end
  
  def edit
    @document = Document.find(params[:id])
  end
  
  def update
    @document = Document.find(params[:id])
    
    if @document.update_attributes(params[:document])
      redirect_to(@document, :notice => 'Document successfully updated.')
    else
      render :edit
    end
  end
  
  def destroy
    @document = Document.find(params[:id])
    @document.destroy

    respond_to do |format|
      format.html { redirect_to(documents_url, :notice => 'Document was successfully destroyed.') }
      format.xml  { head :ok }
    end
  end
end
