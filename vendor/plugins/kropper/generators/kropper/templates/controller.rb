class <%= controller_class_name %>Controller < ApplicationController
  
  def index
    @<%= file_name.pluralize %> = <%= class_name %>.find(:all, :order => 'created_at DESC')
  end
  
  def new
    @<%= file_name %> = <%= class_name %>.new
  end
  
  def create
    @<%= file_name %> = <%= class_name %>.new(params[:<%= file_name %>])
    @<%= file_name %>.save!
    redirect_to crop_<%= file_name %>_path(@<%= file_name %>)
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end

  def show
    @<%= file_name %> = <%= class_name %>.find(params[:id])
  end

  def destroy
    @<%= file_name %> = <%= class_name %>.find(params[:id])
    @<%= file_name %>.destroy
    flash[:notice] = "<%= class_name %> deleted"
    redirect_to <%= file_name.pluralize %>_path
  end
  
  def crop
    @<%= file_name %> = <%= class_name %>.find(params[:id])
    if request.post?
      # we got a post request, so first see if the cancel button was clicked
      if params[:crop_cancel] && params[:crop_cancel] == "true"
        # this means the cancel button was clicked. you might
        # want to implement a more-sophisticated cancel behavior
        # in your app -- for instance, if you store the previous
        # request in the session, you could redirect there instead
        # of to the app's root, as i'm doing here.
        flash[:notice] = "Cropping cancelled."
        redirect_to <%= file_name %>_path(@<%= file_name %>)
        return
      end
      # cancel was not clicked, so crop the image
      @<%= file_name %>.crop! params
      if @<%= file_name %>.save
        flash[:notice] = "<%= class_name %> cropped and saved successfully."
        redirect_to <%= file_name %>_path(@<%= file_name %>)
        return
      end
    end
  rescue <%= class_name %>::InvalidCropRect
    flash[:error] = "Sorry, could not crop the image."
  end
end
