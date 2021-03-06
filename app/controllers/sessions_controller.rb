class SessionsController < ApplicationController 

  def create
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      flash[:success] = "You are now signed in."
      redirect_to root_path
    else
      flash.now[:danger] = "Something went wrong. You are not signed in."
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:success] = "You have been signed out."
    redirect_to root_path
  end

end