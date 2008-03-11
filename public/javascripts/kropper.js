// kropper.js: this file holds the javascript for the Kropper image cropping UI.
// This file depends on prototype.js and dom-drag.js.

// This method sets up the initial position of the image to be cropped
// and the callback methods to be called when the image is dragged,
// the zoom slider handle is dragged, and the reset button is clicked.
// max_zoom determines the maximum zoom-in level for the zoom slider.
function setup_image_cropper(max_zoom)
{
	// make sure the image cropper is on the page...
	if ($("image_cropper"))
	{
		// derive the dimensions of the crop canvas, crop stencil, 
		// and slider range from the browser -- this lets us set the dimensions
		// of the crop canvas, crop stencil, and zoom slider with CSS.
		// IE6 weirdness note: I had to remove the underscores from 
		// the cropcanvas and cropstencil variable names
		// due to a strange error in IE6. Go figure...

		// the crop canvas
		crop_canvas_obj = $("crop_canvas");
		cropcanvas = new Object();
		cropcanvas.w = crop_canvas_obj.clientWidth;
		cropcanvas.h = crop_canvas_obj.clientHeight;
		// the crop stencil
		crop_stencil_obj = $("crop_stencil");
		cropstencil = new Object();
		cropstencil.l = crop_stencil_obj.offsetLeft;
		cropstencil.t = crop_stencil_obj.offsetTop;
		cropstencil.w = crop_stencil_obj.offsetWidth;  // NOTE: includes the width of any CSS border!
		cropstencil.h = crop_stencil_obj.offsetHeight; // NOTE: includes the width of any CSS border!
		cropstencil.aspect_ratio = cropstencil.h / cropstencil.w;
		// the zoom slider
		zoom_slider_obj = $("zoom_slider");
		zoom_slider_handle_obj = $("zoom_slider_handle");
		slider_range = zoom_slider_obj.offsetWidth - zoom_slider_handle_obj.offsetWidth;
		min_zoom = 1; // we want the crop stencil to stay inside the image boundaries, so we can't allow zooming out. This will stop that.

		// set up the initial size of the uncropped image
		uncropped_image_obj = $("uncropped_image");
		img = new Object();
		img.w = uncropped_image_obj.width;
		img.h = uncropped_image_obj.height;
		img.aspect_ratio = (img.h / img.w);
		img.display = new Object(); // this will store the image's current display rect
		if (img.aspect_ratio > cropstencil.aspect_ratio)
		{
			// the image is taller than the crop stencil, so set its width
			// to the width of the crop stencil and let the height overflow
			img.display.orig_w = cropstencil.w;
			img.display.orig_h = cropstencil.w * img.aspect_ratio;
		}
		else
		{
			// the image is wider than the crop stencil, so set its height
			// to the height of the crop stencil and let the width overflow
			img.display.orig_w = cropstencil.h / img.aspect_ratio;
			img.display.orig_h = cropstencil.h;
		}

		// set the initial image position, slider position, and form fields.
		// the initial slider position is for a zoom factor of 1.
		form_params = new Object();
		form_params.crop_left = $("crop_left");
		form_params.crop_top = $("crop_top");
		form_params.crop_width = $("crop_width");
		form_params.crop_height = $("crop_height");
		form_params.stencil_width = $("stencil_width");   
		form_params.stencil_height = $("stencil_height");
		set_initial_positions(uncropped_image_obj, form_params, zoom_slider_handle_obj, img, cropstencil, min_zoom, max_zoom, slider_range );

		// make the image and the slider handle draggable
		image_dragger_obj = $("image_dragger");
		Drag.init(image_dragger_obj, uncropped_image_obj, -5000, 5000, -5000, 5000);
		Drag.init(zoom_slider_handle_obj, null, 0, slider_range, 0, 0);
		
		// set the callbacks to be called when the image and slider handle are dragged
		uncropped_image_obj.onDrag = function(x, y)
		{
			// let the image be dragged around, but make sure the crop stencil
			// always stays inside the image.
			img.display.l = x;
			img.display.t = y;
			img = ensure_stencil_is_inside_image(img, cropstencil);
			set_dom_obj_dimensions(uncropped_image_obj, img.display);
			set_crop_form_params(form_params, img, cropstencil);
		}
		zoom_slider_handle_obj.onDrag = function(x, y)
		{
			// zoom the image in and out around its center.
			slider_pos = x / slider_range;
			zoom = (slider_pos * (max_zoom - min_zoom)) + min_zoom;
			center_x = img.display.l + (img.display.w / 2);
			center_y = img.display.t + (img.display.h / 2);

			img.display.w = img.display.orig_w * zoom;
			img.display.h = img.display.orig_h * zoom;
			img.display.l = center_x - (img.display.w / 2);
			img.display.t = center_y - (img.display.h / 2);
			
			img = ensure_stencil_is_inside_image(img, cropstencil);
			set_dom_obj_dimensions(uncropped_image_obj, img.display);
			set_crop_form_params(form_params, img, cropstencil);
		}
		
		// set the callbacks to be called when the reset link is clicked
		if( $("crop_reset_btn") )
		{
			reset_link = $("crop_reset_btn");
			reset_link.onclick = function()
			{
				set_initial_positions(uncropped_image_obj, form_params, zoom_slider_handle_obj, img, cropstencil, min_zoom, max_zoom, slider_range );
			}
		}
		
		// fade out the loading overlay
		Effect.Fade("crop_loading_overlay");
	}
}

function set_initial_positions(uncropped_image_obj, form_params, zoom_slider_handle_obj, img, cropstencil, min_zoom, max_zoom, slider_range )
{
	img.display.w = img.display.orig_w;
	img.display.h = img.display.orig_h;
	img.display.l = cropstencil.l - ((img.display.w - cropstencil.w) / 2);
	img.display.t = cropstencil.t - ((img.display.h - cropstencil.h) / 2);
	set_dom_obj_dimensions(uncropped_image_obj, img.display);
	set_crop_form_params(form_params, img, cropstencil);
	zoom_slider_handle_obj.style.left = parseInt(((1 - min_zoom) / max_zoom) * slider_range) + 'px';
}

function set_crop_form_params( form_params, img, cropstencil )
{ 
	form_params.crop_left.value = ((cropstencil.l - img.display.l) / img.display.w) * img.w;
	form_params.crop_top.value = ((cropstencil.t - img.display.t) / img.display.h) * img.h;
	form_params.crop_width.value = (cropstencil.w / img.display.w) * img.w;
	form_params.crop_height.value = (cropstencil.h / img.display.h) * img.h;
	form_params.stencil_width.value = cropstencil.w;
	form_params.stencil_height.value = cropstencil.h;
}

function ensure_stencil_is_inside_image(img, cropstencil)
{ 
	// test the left edge
	if( img.display.l > cropstencil.l )
	{
		img.display.l = cropstencil.l;
	}
	// test the top edge
	if( img.display.t > cropstencil.t )
	{
		img.display.t = cropstencil.t;
	}
	// test the right edge
	if( (img.display.l + img.display.w) < (cropstencil.l + cropstencil.w) )
	{
		img.display.l = (cropstencil.l + cropstencil.w) - img.display.w;
	}
	// test the bottom edge
	if( (img.display.t + img.display.h) < (cropstencil.t + cropstencil.h) )
	{
		img.display.t = (cropstencil.t + cropstencil.h) - img.display.h;
	}
	
	return img;
}

// this is currently unused, but would be useful if you are not using
// ensure_stencil_is_inside_image() -- in that case, this method will add
// some stickiness to the stencil edges when dragging the image around.
function process_stencil_stickiness(img, cropstencil, stencil_stickiness)
{ 
	// test the left edge
	if( dist( img.display.l, cropstencil.l ) <= stencil_stickiness )
	{
		img.display.l = cropstencil.l;
	}
	// test the top edge
	if( dist( img.display.t, cropstencil.t ) <= stencil_stickiness )
	{
		img.display.t = cropstencil.t;
	}
	// test the right edge
	if( dist( img.display.l + img.display.w, cropstencil.l + cropstencil.w ) <= stencil_stickiness )
	{
		img.display.l = (cropstencil.l + cropstencil.w) - img.display.w;
	}
	// test the bottom edge
	if( dist( img.display.t + img.display.h, cropstencil.t + cropstencil.h ) <= stencil_stickiness )
	{
		img.display.t = (cropstencil.t + cropstencil.h) - img.display.h;
	}
	
	return img;
}

function set_dom_obj_dimensions(obj, rect)
{
	obj.style.left = rect.l + 'px';
	obj.style.top = rect.t + 'px';
	obj.style.width = rect.w + 'px';
	obj.style.height = rect.h + 'px';
}

function dist(a, b)
{ 
	delta = a - b;
	return Math.sqrt(delta * delta);
}