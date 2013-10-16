class SourceFilesController < ApplicationController
  before_filter :require_login, :except => [:show]
  before_filter :find_user, :only => [:show, :index, :destroy]

  def index
    @source_files = @user.source_files
  end

  def show
    @source_file = @user.source_files.find(params[:id])
    SourceFile.increment_counter(:downloads_count, params[:id])
    redirect_to @source_file.authenticated_s3_url
  end

  def new
    @source_file = SourceFile.new
  end

  # GET /source_files/1/edit
  def edit
  end

  # POST /source_files
  # POST /source_files.xml
  def create
    @source_files = []
    params[:source_file_data].each do |file|
        @source_files << current_user.source_files.create({:uploaded_data => file}) unless file.is_a?(String)
    end
    if @source_files.empty?
      flash[:error] = "Well, either you didn't upload anything, or it wasn't an aiff/wav/zip."
      redirect_to new_user_track_path(current_user)
    else
      flash[:ok] = "Thanks, valued alonetone *plus* user. " 
      flash[:ok] += "We're now hosting the following files for you <br/>" 
      flash[:ok] += @source_files.collect{|f| f.filename }.join(',').html_safe
      redirect_to user_source_files_path(current_user)
    end
  end

  def update
    @source_file = @user.source_file.find(params[:id])
    redirect_to(@source_file) 
  end

  def destroy
    @source_file = @user.source_file.find(params[:id])
    @source_file.destroy
    redirect_to user_source_files_path(@user)
  end
  
  def authorized?
    admin? || (logged_in? && current_user.plus_enabled?)
  end
end
