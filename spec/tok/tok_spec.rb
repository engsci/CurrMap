require 'tok'
require 'yaml'

describe TreeOfKnowledge::Client do 
  before :each do 
    app_root = File.join(File.dirname(__FILE__), '..', '..')
    auth_info = YAML.load_file((File.join(app_root, 'settings.yml')))
    username = auth_info['tok-username']
    password = auth_info['tok-password']
    @client = TreeOfKnowledge::Client.new("localhost", 8080, "/tok-ruby/",
                                          username, password)
  end
  
  it "should allow addition of resources" do
    lambda do
      @client.add_resource('/Knowledge/Math')
    end.should_not raise_error TreeOfKnowledge::ConnectionError
  end
  
  it "should be able to look up resources that have been added" do 
    math = @client.get_resource('/Knowledge/Math')
    math.class.should == Hash
    math['name'].should == 'Math'
  end
  
  it "should fail on non-existant items" do
    lambda do
      @client.get_resource('/Something/Weird')
    end.should raise_error TreeOfKnowledge::ConnectionError
  end
  
  it "should allow adding synonyms" do
    @client.add_resource('/Knowledge/Math')
    @client.add_resource('/Knowledge/Mathematics')
    @client.add_synonym 'Mathematics', 'Math'
    mathematics = @client.get_resource '/Knowledge/Mathematics'
    mathematics['synonyms'].include?('Math').should be_true
  end
  
  it "should allow preferred synonyms" do
    @client.add_resource('/Knowledge/Math')
    @client.add_resource('/Knowledge/Mathematics')
    @client.add_synonym 'Math', 'Mathematics', true
    math = @client.get_resource '/Knowledge/Math'
    math['synonyms'].include?('Mathematics').should be_true
    math['preferred'].should == 'Mathematics'
  end
  
  it "should allow arbitrary relations to be added and retrieved" do
    @client.add_resource '/Knowledge/TensorCalculus'
    @client.add_resource '/Knowledge/CivilEngineering'
    @client.add_relation 'TensorCalculus', :used_in, 'CivilEngineering'
    tcalc = @client.get_resource '/Knowledge/TensorCalculus'
    tcalc['relns'].should_not be_nil
    tcalc['relns'][:used_in].include?('CivilEngineering').should be_true
  end
  
end
