class PeopleController < ApplicationController
  
  load_and_authorize_resource
  
  # GET /people
  # GET /people.xml
  def index
    @people = Person.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @people }
      format.js { 
        render :json => Person.search_as_you_type(params[:term]) 
        }
    end
  end

  # GET /people/1
  # GET /people/1.xml
  def show
    @person = Person.find(params[:id])

    @courses_by_year = {}
    
    @person.course_instances.each do |c|
      @courses_by_year[c.short_code] ||= []
      @courses_by_year[c.short_code] << c
    end
    
    #original form: {short_code1 => [Course1, Course1b]}
    #convert to form: {Course1 => [year, year], Course2 => [year, year]}
    @courses_by_year = @courses_by_year.inject({}) {|result, i| result.merge({i[1][0]=>i[1].map{|c| c.delivered_year}})}
    
    respond_to do |format|
      format.js 
      format.html # show.html.erb
      format.xml  { render :xml => @person }
    end
  end

  # GET /people/new
  # GET /people/new.xml
  def new
    @person = params[:class].classify.constantize.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @person }
    end
  end

  # GET /people/1/edit
  def edit
    @person = Person.find(params[:id])
  end

  # POST /people
  # POST /people.xml
  def create
    if params[:person]
      @person = Person.new(params[:person])
    elsif params[:instructor]
      @person = Instructor.new(params[:instructor])
    end

    respond_to do |format|
      if @person.save && @person.update_attributes(params[@person.class.to_s.underscore.to_sym])
        format.html { redirect_to(@person, :notice => 'Person was successfully created.') }
        format.xml  { render :xml => @person, :status => :created, :location => @person }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /people/1
  # PUT /people/1.xml
  def update
    @person = Instructor.find(params[:id])
    
    respond_to do |format|
      if @person.update_attributes(params[@person.class.to_s.underscore.to_sym])
        format.html { redirect_to(@person, :notice => 'Person was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1
  # DELETE /people/1.xml
  def destroy
    @person = Person.find(params[:id])
    @person.destroy

    respond_to do |format|
      format.html { redirect_to(instructors_url, :notice => 'Record was successfully destroyed.') }
      format.xml  { head :ok }
    end
  end
end
