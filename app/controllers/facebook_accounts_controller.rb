class FacebookAccountsController < ApplicationController
  ensure_application_is_installed_by_facebook_user
  
  before_filter :find_facebook_user
  before_filter :find_alonetone_user
  before_filter :check_for_correct_params, :only => [:add_to_profile, :remove_from_profile]
  
  def index
    @assets = Asset.paginate(:all, :include => :user, :per_page => 10, :order => 'assets.created_at DESC', :page => params[:page])
    @search_assets = Asset.find(:all, :select => 'id, title, filename', :limit => 200)
  end
  
  def create
    
  end
  
  def add_to_profile
   # one word: Fugly
   @addable = FacebookAddable.find_or_create_by_profile_chunk_type_and_profile_chunk_id_and_facebook_account_id(:profile_chunk_type => params[:addable_type].capitalize,
                  :profile_chunk_id => (params[:addable_id_val] || params[:addable_id]), :facebook_account_id => @facebook_account.id)
   if @addable
     flash[:notice] = "Profile updated! We added that killer track"
     @facebook_user.profile_fbml = (render_to_string :partial => 'profile')
   else 
     flash[:error] = "Hm, that failed to add to your profile"
   end
     redirect_to facebook_home_path
  end
  
  def remove_from_profile
    @addable = FacebookAddable.find_by_facebook_account_id(@facebook_account.id, :conditions => {:profile_chunk_type => params[:addable_type], :profile_chunk_id => params[:addable_id]})
    if @addable && @addable.destroy
      flash[:notice] = "Profile updated! We removed that track."
      if @facebook_account.facebook_addables.find(:all).size > 0
        @facebook_user.profile_fbml = (render_to_string :partial => 'profile')
      else
        @facebook_user.profile_fbml = (render_to_string :partial => 'default_profile')
      end
    else
      flash[:error] = "Whups. huh. That didn't do what you wanted it to do."
    end
    redirect_to facebook_home_path
  end
  
  protected
  
  def check_for_correct_params
    unless params[:addable_type] && params[:addable_id]
      flash[:error] = "Whups, that wasn't possible"
      redirect_to facebook_path and return false
    end
  end
  
  def find_alonetone_user
    @user = current_user if logged_in?
  end
  
  def find_facebook_user
    @facebook_user = session[:facebook_session].user
    @facebook_account = FacebookAccount.find_or_create_by_fb_user_id(@facebook_user.id)
  end

  
end
