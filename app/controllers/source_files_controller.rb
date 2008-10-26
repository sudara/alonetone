class SourceFilesController < ApplicationController
  before_filter :login_required, :except => [:show]
  before_filter :find_user, :only => [:show, :index, :destroy]
  # GET /source_files
  # GET /source_files.xml
  def index
    @source_files = @user.source_files.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @source_files }
    end
  end

  # GET /source_files/1
  # GET /source_files/1.xml
  def show
    @source_file = @user.source_files.find(params[:id])
    SourceFile.increment_counter(:downloads_count, params[:id])
    redirect_to @source_file.authenticated_s3_url
  end

  # GET /source_files/new
  # GET /source_files/new.xml
  def new
    @source_file = SourceFile.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @source_file }
    end
  end

  # GET /source_files/1/edit
  def edit
    @source_file = SourceFile.find(params[:id])
  end

  # POST /source_files
  # POST /source_files.xml
  def create
    params[:source_file_data] ||= []
    @source_files = []
    params[:source_file_data].each do |file|
      unless file.is_a?(String)
        @source_files << current_user.source_files.create({:uploaded_data => file})
      end
    end
    if @source_files.empty?
      flash[:error] = "Well, either you didn't upload anything, " << 
                      "it wasn't an aiff/wav/zip, or we're failing you somehow"
                      
      redirect_to new_user_track_path(current_user)
    else
      flash[:ok] =  "Thanks, valued alonetone *plus* user. " << 
                    "We're hosting the following files for you <br/>" <<
                    @source_files.collect{|f| f.filename }.join(',')

      redirect_to user_source_files_path(current_user)
    end
  end

  # PUT /source_files/1
  # PUT /source_files/1.xml
  def update
    @source_file = SourceFile.find(params[:id])

    respond_to do |format|
      if @source_file.update_attributes(params[:source_file])
        flash[:notice] = 'SourceFile was successfully updated.'
        format.html { redirect_to(@source_file) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @source_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /source_files/1
  # DELETE /source_files/1.xml
  def destroy
    @source_file = @user.source_file.find(params[:id])
    @source_file.destroy
    redirect_to user_source_files_path(@user)
  end
  
  def authorized?
    admin? || (logged_in? && current_user.plus_enabled?)
  end
end
