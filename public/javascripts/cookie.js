var Cookie = {
  version: '0.7',
  cookies: {},
  _each: function(iterator) {
    $H(this.cookies).each(iterator);
  },
  
  getAll: function() {
    this.cookies = {};
    $A(document.cookie.split('; ')).each(function(cookie) {
      var seperator = cookie.indexOf('=');
      this.cookies[cookie.substring(0, seperator)] = 
          unescape(cookie.substring(seperator + 1, cookie.length));
    }.bind(this));
    return this.cookies;
  },
  
  read: function() {
    var cookies = $A(arguments), results = [];
    this.getAll();
    cookies.each(function(name) {
      if (this.cookies[name]) results.push(this.cookies[name]);
      else results.push(null);
    }.bind(this));
    return results.length > 1 ? results : results[0];
  },
  
  write: function(cookies, options) {
    if (cookies.constructor == Object && cookies.name) cookies = [cookies];
    if (cookies.constructor == Array) {
      $A(cookies).each(function(cookie) {
        this._write(cookie.name, cookie.value, cookie.expires,
                    cookie.path, cookie.domain);
      }.bind(this));
    }else {
      options = options || {expires: false, path: '', domain: ''};
      for (name in cookies){
        this._write(name, cookies[name],
                    options.expires, options.path, options.domain);
      }
    }
  },
  
  _write: function(name, value, expires, path, domain) {
    if (name.indexOf('=') != -1) return;
    var cookieString = name + '=' + escape(value);
    if (expires) cookieString += '; expires=' + expires.toGMTString();
    if (path) cookieString += '; path=' + path;
    if (domain) cookieString += '; domain=' + domain;
    document.cookie = cookieString;
  },
  
  erase: function(cookies) {
    var cookiesToErase = {};
    $A(arguments).each(function(cookie) {
      cookiesToErase[cookie] = '';
    });
    
    this.write(cookiesToErase, {expires: (new Date((new Date()).getTime() - 1e11))});
    this.getAll();
  },
  
  eraseAll: function() {
    this.erase.apply(this, $H(this.getAll()).keys());
  }
};

Object.extend(Cookie, {
  get: Cookie.read,
  set: Cookie.write,
  
  add: Cookie.read,
  remove: Cookie.erase,
  removeAll: Cookie.eraseAll,
  
  wipe: Cookie.erase,
  wipeAll: Cookie.eraseAll,
  destroy: Cookie.erase,
  destroyAll: Cookie.eraseAll
});
