// Returns array with x,y page scroll values.
// Core code from - quirksmode.org
Position.getPageScroll = function() {
  if(self.pageYOffset)
    return self.pageYOffset;
  if(document.documentElement && document.documentElement.scrollTop) // Explorer 6 Strict
    return document.documentElement.scrollTop;
  if(document.body) // all other Explorers
    return document.body.scrollTop;
}

// Returns array with page width, height and window width, height
// Core code from - quirksmode.org
// Edit for Firefox by pHaez
Position.getPageSize = function() {
  var xScroll, yScroll;

  if (window.innerHeight && window.scrollMaxY) {  
    xScroll = document.body.scrollWidth;
    yScroll = window.innerHeight + window.scrollMaxY;
  } else if (document.body.scrollHeight > document.body.offsetHeight){ // all but Explorer Mac
    xScroll = document.body.scrollWidth;
    yScroll = document.body.scrollHeight;
  } else { // Explorer Mac...would also work in Explorer 6 Strict, Mozilla and Safari
    xScroll = document.body.offsetWidth;
    yScroll = document.body.offsetHeight;
  }

  var windowWidth, windowHeight;
  if (self.innerHeight) { // all except Explorer
    windowWidth = self.innerWidth;
    windowHeight = self.innerHeight;
  } else if (document.documentElement && document.documentElement.clientHeight) { // Explorer 6 Strict Mode
    windowWidth = document.documentElement.clientWidth;
    windowHeight = document.documentElement.clientHeight;
  } else if (document.body) { // other Explorers
    windowWidth = document.body.clientWidth;
    windowHeight = document.body.clientHeight;
  } 

  // for small pages with total height less then height of the viewport
  pageHeight = Math.max(windowHeight, yScroll);

  // for small pages with total width less then width of the viewport
  pageWidth = Math.max(windowWidth, xScroll);

  return { page: { width: pageWidth, height: pageHeight }, window: { width: windowWidth, height: windowHeight } };
}

var Dialog = {
  clearObservers: function() {
    if (!Dialog.resizeObserver) return;    
    Event.stopObserving(window, 'resize', Dialog.resizeObserver);
    Event.stopObserving(window, 'scroll', Dialog.resizeObserver);
    Dialog.resizeObserver = null;
    Dialog.current        = null;
  },

  close: function() {
    this.onCallback('onClose');
    this.clearObservers();
    ['dialog', 'dialog-box'].each(function(d) { if($(d)) Element.remove(d); });
  },

  onCallback: function(callback) {
    if(Dialog.current.options[callback]) Dialog.current.options[callback]();
  },
  
  Base: Class.create()
};

Dialog.Base.prototype = {
  defaultOptions: {},

  initialize: function(options) {
    this.options = Object.extend(Object.extend({}, this.defaultOptions), options);
    this.create();
  },

  setupDialog: function() {
    this.createDialogElements();
    this.setContents();
  },

  setContents: function() {
    // this.dialogBox.innerHTML = ....
  },

  createDialogElements: function() {
    this.dialog    = document.createElement('div');
    this.dialogBox = document.createElement('div');
    this.dialog.setAttribute('id', 'dialog');
    this.dialogBox.setAttribute('id', 'dialog-box');
    Element.setStyle(this.dialog,    {zIndex: 100});
    Element.setStyle(this.dialogBox, {zIndex: 101, display:'none'});
  },

  create: function() {
    this.setupDialog();
    document.body.appendChild(this.dialog);
    document.body.appendChild(this.dialogBox);
    this.afterCreate();
  },
  
  afterCreate: function() {
    this.layout();
    Dialog.resizeObserver = this.layout.bind(this);
    Event.observe(window, 'resize', Dialog.resizeObserver);
    Event.observe(window, 'scroll', Dialog.resizeObserver);

    new Effect.Fade(this.dialog, {from: 0.1, to: 0.4, duration:0.15});
    new Effect.Appear(this.dialogBox, {duration:0.4});
    Dialog.current = this;
  },

  layout: function() {
    var pg_dimensions = Position.getPageSize();
    var el_dimensions = Element.getDimensions('dialog-box');
    var scrollY       = Position.getPageScroll();
    
    Element.setStyle('dialog', {
      position:'absolute', top:0, left:0,
      width: pg_dimensions.page.width  + 'px',
      height:pg_dimensions.page.height + 'px'
    });

    Element.setStyle('dialog-box', {
      position:'absolute',
      top:  ((pg_dimensions.window.height - el_dimensions.height) / 2) + scrollY + 'px',
      left: ((pg_dimensions.page.width    - el_dimensions.width)  / 2) + 'px'
    })
  },

  close: function() {
    new Effect.Fade('dialog-box', {duration: 0.2, afterFinish: function() { Dialog.close(); }});
  }
};

Dialog.Rjs = Class.create();
Object.extend(Object.extend(Dialog.Rjs.prototype, Dialog.Base.prototype), {
  defaultOptions: Object.extend(Object.extend({}, Dialog.Base.prototype.defaultOptions), {}),
  setContents: function() {
    this.dialogBox.innerHTML = '<p>Loading...</p><p><a href="#" onclick="Dialog.close(); return false;">close</a>';
  }
});