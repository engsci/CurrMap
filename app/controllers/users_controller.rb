class UsersController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:edit_roles]

  def index
   @users = User.find(:all)
  end
 
  def show
  end

  def new
  end

  def edit
    @user = User.find(params[:id])
    render :action=>"index"
  end

  def create
  end

  def update
    user = User.find(params[:id])
    params[:user].keys.each do |role_name|
      if params[:user][role_name] == "1"
        user.add_role(role_name)
      else
        user.remove_role(role_name)
      end
    end
    if user.save
      flash[:notice] = "Roles for " + user.email + " successfully changed."
    end
    redirect_to :action=>"index"
      
  end

  def destroy
  end
end
