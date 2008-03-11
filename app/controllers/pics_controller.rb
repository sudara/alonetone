class PicsController < ApplicationController
  # GET /pics
  # GET /pics.xml
  def index
    @pics = Pic.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pics }
    end
  end

  # GET /pics/1
  # GET /pics/1.xml
  def show
    @pic = Pic.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @pic }
    end
  end

  # GET /pics/new
  # GET /pics/new.xml
  def new
    @pic = Pic.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @pic }
    end
  end

  # GET /pics/1/edit
  def edit
    @pic = Pic.find(params[:id])
  end

  # POST /pics
  # POST /pics.xml
  def create
     @pic = Pic.new(params[:Pic])
     @pic.save!
     redirect_to crop_Pic_path(@pic)
   rescue ActiveRecord::RecordInvalid
     render :action => 'new'
  end

  def crop
     @pic = Pic.find(params[:id])
     if request.post?
       # we got a post request, so first see if the cancel button was clicked
       if params[:crop_cancel] && params[:crop_cancel] == "true"
         # this means the cancel button was clicked. you might
         # want to implement a more-sophisticated cancel behavior
         # in your app -- for instance, if you store the previous
         # request in the session, you could redirect there instead
         # of to the app's root, as i'm doing here.
         flash[:notice] = "Cropping cancelled."
         redirect_to pic_path(@pic)
         return
       end
       # cancel was not clicked, so crop the image
       @pic.crop! params
       if @pic.save
         flash[:notice] = "Pic cropped and saved successfully."
         redirect_to pic_path(@pic)
         return
       end
     end
   rescue Pic::InvalidCropRect
     flash[:error] = "Sorry, could not crop the image."
   end

  # PUT /pics/1
  # PUT /pics/1.xml
  def update
    @pic = Pic.find(params[:id])

    respond_to do |format|
      if @pic.update_attributes(params[:pic])
        flash[:notice] = 'Pic was successfully updated.'
        format.html { redirect_to(@pic) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @pic.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /pics/1
  # DELETE /pics/1.xml
  def destroy
    @pic = Pic.find(params[:id])
    @pic.destroy

    respond_to do |format|
      format.html { redirect_to(pics_url) }
      format.xml  { head :ok }
    end
  end
end
