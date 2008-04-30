class UserReportsController < ApplicationController
  
  before_filter :login_required, :except => [:index, :show, :new, :create]
  
  # GET /user_reports
  # GET /user_reports.xml
  def index
    @user_reports = UserReport.valid.paginate(:all, :include => :user, :order => 'user_reports.created_at DESC', :per_page => 15, :page => params[:page])
    @page_title = "Feedback about alonetone"
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_reports }
      format.rss  
    end
  end

  # GET /user_reports/1
  # GET /user_reports/1.xml
  def show
    @user_reports = UserReport.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user_reports }
    end
  end

  # GET /user_reports/new
  # GET /user_reports/new.xml
  def new
    @user_reports = UserReport.new(params[:user_report])

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_reports }
    end
  end

  # GET /user_reports/1/edit
  def edit
    @user_reports = UserReport.find(params[:id])
  end

  # POST /user_reports
  # POST /user_reports.xml
  def create
    params = slice_and_dice_params
    if logged_in?
      @user_report = current_user.user_reports.create(params[:user_report])
    else
      @user_report = UserReport.create(params[:user_report])
    end
    respond_to do |format|
      format.js do
        if @user_report 
           @user_report.env = request.env
           return head(:created)
         else
           return head(:bad_request)
         end
         render :nothing => true
      end
    end
  end

  # PUT /user_reports/1
  # PUT /user_reports/1.xml
  def update
    @user_reports = UserReport.find(params[:id])

    respond_to do |format|
      if @user_reports.update_attributes(params[:user_report])
        flash[:notice] = 'UserReport was successfully updated.'
        format.html { redirect_to(@user_reports) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_reports.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_reports/1
  # DELETE /user_reports/1.xml
  def destroy
    @user_reports = UserReport.find(params[:id])
    @user_reports.destroy

    respond_to do |format|
      format.html { redirect_to(user_reports_url) }
      format.xml  { head :ok }
    end
  end
  
  protected
  
  def slice_and_dice_params
    # no auth token
    params.delete(:authenticity_token)
    params[:user_report][:params][:request] = request.env
    params
  end
  
  def authorized?
    admin?
  end
end
