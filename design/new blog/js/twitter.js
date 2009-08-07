/**
 * remy sharp / http://remysharp.com
 * http://remysharp.com/2007/05/18/add-twitter-to-your-blog-step-by-step/
 *
 * @params
 *   cssIdOfContainer: e.g. twitters
 *   options: 
 *       {
 *           id: {String} username,
 *           count: {Int} 1-20, defaults to 1 - max limit 20
 *           prefix: {String} '%name% said', defaults to blank
 *           clearContents: {Boolean} true, removes contents of element specified in cssIdOfContainer, defaults to true
 *           ignoreReplies: {Boolean}, skips over tweets starting with '@', defaults to false
 *           template: {String} HTML template to use for LI element (see URL above for examples), defaults to predefined template
 *           enableLinks: {Boolean} linkifies text, defaults to true,
 *           timeout: {Int} How long before triggering onTimeout, defaults to 10 seconds if onTimeout is set
 *           onTimeoutCancel: {Boolean} Completely cancel twitter call if timedout, defaults to false
 *           onTimeout: {Function} Function to run when the timeout occurs. Function is bound to element specified with 
 *              cssIdOfContainer (i.e. 'this' keyword)
 *
 *      CURRENTLY DISABLED DUE TO CHANGE IN TWITTER API:
 *           withFriends: {Boolean} includes friend's status
 *
 *       }
 *
 * @license MIT (MIT-LICENSE.txt)
 * @version 1.12.2 - Fixed Safari 4 returning blank by using simple cache busting
 * @date $Date: 2009-03-09 09:46:25 +0000 (Mon, 09 Mar 2009) $
 */

// to protect variables from resetting if included more than once
if (typeof renderTwitters != 'function') (function () {
    /** Private variables */
    var browser = (function() {
    	var b = navigator.userAgent.toLowerCase();

    	// Figure out what browser is being used
    	return {
    		safari: /webkit/.test(b),
    		opera: /opera/.test(b),
    		msie: /msie/.test(b) && !(/opera/).test(b),
    		mozilla: /mozilla/.test(b) && !(/(compatible|webkit)/).test(b)
    	};
    })();

    var guid = 0;
    var readyList = [];
    var isReady = false;
    
    /** Global functions */
    
    // to create a public function within our private scope, we attach the 
    // the function to the window object
    window.renderTwitters = function (obj, options) {
        // private shortcuts
        function node(e) {
            return document.createElement(e);
        }
        
        function text(t) {
            return document.createTextNode(t);
        }

        var target = document.getElementById(options.twitterTarget);
        var data = null;
        var ul = node('ul'), li, statusSpan, timeSpan, i, max = obj.length > options.count ? options.count : obj.length;
        
        for (i = 0; i < max && obj[i]; i++) {
            data = getTwitterData(obj[i]);
                        
            if (options.ignoreReplies && obj[i].text.substr(0, 1) == '@') {
                max++;
                continue; // skip
            }
            
            li = node('li');
            
            if (options.template) {
                li.innerHTML = options.template.replace(/%([a-z_\-\.]*)%/ig, function (m, l) {
                    var r = data[l] + "" || "";
                    if (l == 'text' && options.enableLinks) r = linkify(r);
                    return r;
                });
            } else {
                statusSpan = node('span');
                statusSpan.className = 'twitterStatus';
                timeSpan = node('span');
                timeSpan.className = 'twitterTime';
                statusSpan.innerHTML = obj[i].text; // forces the entities to be converted correctly

                if (options.enableLinks == true) {
                    statusSpan.innerHTML = linkify(statusSpan.innerHTML);
                }

                timeSpan.innerHTML = relative_time(obj[i].created_at);

                if (options.prefix) {
                    var s = node('span');
                    s.className = 'twitterPrefix';
                    s.innerHTML = options.prefix.replace(/%(.*?)%/g, function (m, l) {
                        return obj[i].user[l];
                    });
                    li.appendChild(s);
                    li.appendChild(text(' ')); // spacer :-(
                }

                li.appendChild(statusSpan);
                li.appendChild(text(' '));
                li.appendChild(timeSpan);
            }
            
            ul.appendChild(li);
        }

        if (options.clearContents) {
            while (target.firstChild) {
                target.removeChild(target.firstChild);
            }
        }

        target.appendChild(ul);
    };
    
    window.getTwitters = function (target, id, count, options) {
        guid++;
        

        if (typeof id == 'object') {
            options = id;
            id = options.id;
            count = options.count;
        } 

        // defaulting options
        if (!count) count = 1;
        
        if (options) {
            options.count = count;
        } else {
            options = {};
        }
        
        if (!options.timeout && typeof options.onTimeout == 'function') {
            options.timeout = 10;
        }
        
        if (typeof options.clearContents == 'undefined') {
            options.clearContents = true;
        }
        
        // Hack to disable withFriends, twitter changed their API so this requires auth
        // http://getsatisfaction.com/twitter/topics/friends_timeline_api_call_suddenly_requires_auth
        if (options.withFriends) options.withFriends = false;

        // need to make these global since we can't pass in to the twitter callback
        options['twitterTarget'] = target;
        
        // default enable links
        if (typeof options.enableLinks == 'undefined') options.enableLinks = true;

        // this looks scary, but it actually allows us to have more than one twitter
        // status on the page, which in the case of my example blog - I do!
        window['twitterCallback' + guid] = function (obj) {
            if (options.timeout) {
                clearTimeout(window['twitterTimeout' + guid]);
            }
            renderTwitters(obj, options);
        };

        // check out the mad currying!
        ready((function(options, guid) {
            return function () {
                // if the element isn't on the DOM, don't bother
                if (!document.getElementById(options.twitterTarget)) {
                    return;
                }
                
                var url = 'http://www.twitter.com/statuses/' + (options.withFriends ? 'friends_timeline' : 'user_timeline') + '/' + id + '.json?callback=twitterCallback' + guid + '&count=20&cb=' + Math.random();

                if (options.timeout) {
                    window['twitterTimeout' + guid] = setTimeout(function () {
                        // cancel callback
                        if (options.onTimeoutCancel) window['twitterCallback' + guid] = function () {};
                        options.onTimeout.call(document.getElementById(options.twitterTarget));
                    }, options.timeout * 1000);
                }
                
                var script = document.createElement('script');
                script.setAttribute('src', url);
                document.getElementsByTagName('head')[0].appendChild(script);
            };
        })(options, guid));
    };
    
    // GO!
    DOMReady();
    

    /** Private functions */
    
    function getTwitterData(orig) {
        var data = orig, i;
        for (i in orig.user) {
            data['user_' + i] = orig.user[i];
        }
        
        data.time = relative_time(orig.created_at);
        
        return data;
    }
    
    function ready(callback) {
        if (!isReady) {
            readyList.push(callback);
        } else {
            callback.call();
        }
    }
    
    function fireReady() {
        isReady = true;
        var fn;
        while (fn = readyList.shift()) {
            fn.call();
        }
    }

    // ready and browser adapted from John Resig's jQuery library (http://jquery.com)
    function DOMReady() {
        if ( browser.mozilla || browser.opera ) {
            document.addEventListener( "DOMContentLoaded", fireReady, false );
        } else if ( browser.msie ) {
            // If IE is used, use the excellent hack by Matthias Miller
            // http://www.outofhanwell.com/blog/index.php?title=the_window_onload_problem_revisited

            // Only works if you document.write() it
            document.write("<scr" + "ipt id=__ie_init defer=true src=//:><\/script>");

            // Use the defer script hack
            var script = document.getElementById("__ie_init");

            // script does not exist if jQuery is loaded dynamically
            if (script) {
                script.onreadystatechange = function() {
                    if ( this.readyState != "complete" ) return;
                    this.parentNode.removeChild( this );
                    fireReady.call();
                };
            }

            // Clear from memory
            script = null;

            // If Safari  is used
        } else if ( browser.safari ) {
            // Continually check to see if the document.readyState is valid
            var safariTimer = setInterval(function () {
                // loaded and complete are both valid states
                if ( document.readyState == "loaded" || 
                document.readyState == "complete" ) {

                    // If either one are found, remove the timer
                    clearInterval( safariTimer );
                    safariTimer = null;
                    // and execute any waiting functions
                    fireReady.call();
                }
            }, 10);
        }
    }
    
    function relative_time(time_value) {
        var values = time_value.split(" "),
            parsed_date = Date.parse(values[1] + " " + values[2] + ", " + values[5] + " " + values[3]),
            date = new Date(parsed_date),
            relative_to = (arguments.length > 1) ? arguments[1] : new Date(),
            delta = parseInt((relative_to.getTime() - parsed_date) / 1000),
            r = '';
        
        function formatTime(date) {
            var hour = date.getHours(),
                min = date.getMinutes() + "",
                ampm = 'AM';
            
            if (hour == 0) {
                hour = 12;
            } else if (hour > 12) {
                hour -= 12;
                ampm = 'PM';
            }
            
            if (min.length == 1) {
                min = '0' + min;
            }
            
            return hour + ':' + min + ' ' + ampm;
        }
        
        function formatDate(date) {
            var ds = date.toDateString().split(/ /),
                mon = ds[1],
                day = ds[2],
                dayi = parseInt(day),
                year = date.getFullYear(),
                thisyear = (new Date()).getFullYear(),
                th = 'th';
            
            // anti-'th' - but don't do the 11th, 12th or 13th
            if ((dayi % 10) == 1 && day.substr(0, 1) != '1') {
                th = 'st';
            } else if ((dayi % 10) == 2 && day.substr(0, 1) != '1') {
                th = 'nd';
            } else if ((dayi % 10) == 3 && day.substr(0, 1) != '1') {
                th = 'rd';
            }
            
            if (day.substr(0, 1) == '0') {
                day = day.substr(1);
            }
            
            return mon + ' ' + day + th + (thisyear != year ? ', ' + year : '');
        }
        
        delta = delta + (relative_to.getTimezoneOffset() * 60);

        if (delta < 5) {
            r = 'less than 5 seconds ago';
        } else if (delta < 30) {
            r = 'half a minute ago';
        } else if (delta < 60) {
            r = 'less than a minute ago';
        } else if (delta < 120) {
            r = '1 minute ago';
        } else if (delta < (45*60)) {
            r = (parseInt(delta / 60)).toString() + ' minutes ago';
        } else if (delta < (2*90*60)) { // 2* because sometimes read 1 hours ago
            r = 'about 1 hour ago';
        } else if (delta < (24*60*60)) {
            r = 'about ' + (parseInt(delta / 3600)).toString() + ' hours ago';
        } else {
            if (delta < (48*60*60)) {
                r = formatTime(date) + ' yesterday';
            } else {
                r = formatTime(date) + ' ' + formatDate(date);
                // r = (parseInt(delta / 86400)).toString() + ' days ago';
            }
        }

        return r;
    }
    
    function linkify(s) {
        var entities = {
            '"' : '&quot;',
            '&' : '&amp;',
            '<' : '&lt;',
            '>' : '&gt;'
        };
        
        return s.replace(/[A-Za-z]+:\/\/[A-Za-z0-9-_]+\.[A-Za-z0-9-_:%&\?\/.=]+/g, function(m) {
            return m.link(m);
        }).replace(/(^|[^\w])(@[\d\w\-]+)/g, function(d, m1, m2) {
            return m1 + '@<a href="http://twitter.com/' + m2.substr(1) + '">' + m2.substr(1) + '</a>';
        }).replace(/"&<>/, function (m) {
            return entities[m];
        });
    }
})();