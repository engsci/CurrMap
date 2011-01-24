class User
  include Mongoid::Document  
  include Roles::Mongoid 

  strategy :role_string
  valid_roles_are :admin, :prof, :student, :guest	

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable, :rememberable, :timeoutable
  devise :database_authenticatable, :recoverable, :trackable, :validatable, :registerable
  
end
