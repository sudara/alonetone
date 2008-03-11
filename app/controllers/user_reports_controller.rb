class UserReportsController < ApplicationController
  
  before_filter :login_required, :except => [:index, :show, :new, :create]
  
  # GET /user_reports
  # GET /user_reports.xml
  def index
    @user_reports = UserReport.find_all_by_spam(false, :include => :user, :order => 'user_reports.created_at DESC')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_reports }
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
    @user_report = UserReport.new(params[:user_report])
    @user_report.env = request.env
    respond_to do |format|
      if @user_report.save
        flash[:ok] = 'Got it, thanks for taking the time!'
        format.html { redirect_to_default }
        format.xml  { render :xml => @user_report, :status => :created, :location => @user_reports }
        format.js { render :nothing => true}
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_report.errors, :status => :unprocessable_entity }
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
  
  def authorized?
    admin?
  end
end
