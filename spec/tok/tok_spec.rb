require 'tok'
require 'yaml'

describe TreeOfKnowledge::Client do 
  before :each do 
    app_root = File.join(File.dirname(__FILE__), '..', '..')
    auth_info = YAML.load_file((File.join(app_root, 'settings.yml')))
    username = auth_info['username']
    password = auth_info['password']
    @client = TreeOfKnowledge::Client.new("localhost", 9090, "/tok-ruby/",
                                          username, password)
  end
  
  it "should allow addition of resources" do
    lambda do
      @client.add_resource('/Knowledge/Math')
    end.should_not raise_error
  end
  
  it "should be able to look up resources that have been added" do 
    math = @client.get_resource('/Knowledge/Math')
    math.class.should == Hash
    math['name'].should == 'Math'
  end
  
  it "should fail on non-existant items" do 
    lambda do
      @client.get_resource('/Something/Weird')
    end.should raise_error
  end
  
end
