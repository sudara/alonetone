class FacebookAccountsController < ApplicationController
  ensure_application_is_installed_by_facebook_user
  
  before_filter :find_facebook_user
  before_filter :find_alonetone_user
  before_filter :check_for_correct_params, :only => [:add_to_profile, :remove_from_profile]
  skip_before_filter :verify_authenticity_token
  
  def index
    @latest = Asset.paginate( :all, 
      :include  => {:user => :pic}, 
      :per_page => 10, 
      :order    => 'assets.created_at DESC', 
      :page     => params[:page]
    )
    
    @kicking_ass = Asset.paginate( :all, 
      :include  => {:user => :pic}, 
      :per_page => 10, 
      :order    => 'assets.hotness DESC', 
      :page     => params[:page]
    )
    
    @show_user = true
  end
  
  def create
    
  end
  
  def add_to_profile
    # one word: Fugly
    @addable = FacebookAddable.find_or_create_by_profile_chunk_type_and_profile_chunk_id_and_facebook_account_id(
      :profile_chunk_type   => params[:addable_type].capitalize,
      :profile_chunk_id     => params[:addable_id_val] || params[:addable_id], 
      :facebook_account_id  => @facebook_account.id
    )
    
   @asset = Asset.find(params[:addable_id])
   if @addable && @asset
     flash[:notice] = "Profile updated! We added that killer track"
     begin
       FacebookPublisher.deliver_track_added(facebook_session.user, @asset)
     rescue Facebooker::Session::TooManyUserActionCalls, Facebooker::Session::InvalidFeedTitleLength
     end
     @facebook_user.profile_fbml = (render_to_string :partial => 'profile')
     @assets = @facebook_account.assets
   else 
     flash[:error] = "Hm, that failed to add to your profile"
   end
  end
  
  def remove_from_profile
    @addable = FacebookAddable.find_by_facebook_account_id( @facebook_account.id, 
      :conditions => {  :profile_chunk_type => params[:addable_type], 
                        :profile_chunk_id   => params[:addable_id  ]  }
    )
    if @addable && @addable.destroy
      flash[:notice] = "Profile updated! We removed that track."
      part = @facebook_account.facebook_addables.count > 0 ? 'profile' : 'default_profile'
      @facebook_user.profile_fbml = render_to_string :partial => part
    else
      flash[:error] = "Whups. huh. That didn't do what you wanted it to do."
    end
    redirect_to session[:return_to] || facebook_home_path
  end
  
  protected
  
  def sorry
    flash.delete(:notice)
    flash[:error] = "Shoot, Facebook only lets you add/remove tracks a handful of times a day. "   <<
                    "We're sorry. Come back tomorrow? Pretty please? Alonetone itself loves you. " << 
                    "You can always just go hang out with us. We're cooler than facebook anyway."
    redirect_to facebook_home_path
  end
  
  def check_for_correct_params
    unless params[:addable_type] && params[:addable_id]
      flash[:error] = "Whups, that wasn't possible"
      redirect_to facebook_path and return false
    end
  end
  
  def find_alonetone_user
    if params[:user_id]
      @user = User.find(params[:user_id])
      unless @user.facebook_account 
        @user.facebook_account = @facebook_account
        @user.save
      end
    end
  end
  
  def find_facebook_user
    @facebook_user = session[:facebook_session].user
    @facebook_account = FacebookAccount.find_or_create_by_fb_user_id(@facebook_user.id)
  end  
end