class PasswordResetsController < ApplicationController  
  
  before_filter :load_user_using_perishable_token, :only => [:edit, :update]  
  
  
  def edit
  end
  
  def create  
    email = params[:email].present? ? params[:email].first : nil
    @user = User.where(:email => email).first 
    if @user.present? 
      @user.reset_perishable_token!
      UserNotification.forgot_password(@user).deliver_now
      flash[:notice] = "Check your email and click the link to reset your password!"
      redirect_to login_path
    else  
      flash[:error] = "Uhm. Uh oh. No user was found with that email address, maybe it was a different email?"  
      redirect_to login_path
    end  
  end  
  
  def update  
    @user.password = params[:user][:password]  
    @user.password_confirmation = params[:user][:password_confirmation]  
    if @user.save  
      flash[:notice] = "Password successfully updated! Enjoy a much easier life from here on out."  
      @user.clear_token!
      UserSession.create(@user, true)
      redirect_to user_home_path(@user.login)  
    else 
      flash[:error] = "Please try again. #{@user.errors.full_messages.join('<br/>')}"
      redirect_to edit_password_reset_path(@user.perishable_token)
    end  
  end  

  private  
 
  def load_user_using_perishable_token  
    @user = User.where(:perishable_token => params[:id]).first 
    unless @user.present?
      flash[:error] = "Hmmm...that didn't work. If you still have issues, email #{Alonetone.email}"
      redirect_to login_path
    end
    true
  end
  
end
