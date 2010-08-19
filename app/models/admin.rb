class Admin
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable, :rememberable, :timeoutable, :registerable
  devise :database_authenticatable,
         :recoverable, :trackable, :validatable

end
