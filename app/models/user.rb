class User
  include Mongoid::Document  
  include Roles::Mongoid 
  before_create :add_default_role
  
  strategy :role_strings
  valid_roles_are :admin, :prof, :student, :guest	
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable, :rememberable, :timeoutable
  devise :database_authenticatable, :recoverable, :trackable, :validatable, :registerable
  
  protected
  def add_default_role
    if self.roles.empty?
      self.role = :guest
    end
  end
 
end
