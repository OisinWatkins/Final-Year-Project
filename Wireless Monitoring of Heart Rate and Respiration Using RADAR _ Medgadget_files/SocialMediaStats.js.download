/** 
 * By 404it, https://www.404it.no/en/
 * License: Free to use as you please. If you redistribute, in original or in modified form, you must reference the documentation page. No warranty whatsoever.
 * Documentation: https://www.404it.no/en/blog/javascript_class_for_getting_url_shares_on_facebook_twitter_linkedin
*/

/**
 * Constructor.
 * @param {string} url - URL you want to get stats for. Must be absolute and complete, i.e. https://www.google.com/.
 */
function SocialMediaStats(url) {

	this.url=url;
	this.urlFacebook='https://graph.facebook.com/';
	this.urlTwitter='https://cdn.api.twitter.com/1/urls/count.json';
	this.urlLinkedIn='https://www.linkedin.com/countserv/count/share';

	/**
	 * Get share data from Facebook as an object. Object contains all data received from Facebook.
	 * @param {requestCallback} callback - callback for response, 1 parameter, example: myFunction(result).
	 */
	SocialMediaStats.prototype.facebook = function(callback) {
		this.getJson(this.urlFacebook+'?id='+this.url, this.getJsonCallback, callback);
	}
	
	/**
	 * Get share data from Twitter as an object. Object contains all data received from Twitter.
	 * @param {requestCallback} callback - callback for response, 1 parameter, example: myFunction(result).
	 */	
	SocialMediaStats.prototype.twitter = function(callback) {
		this.getJsonp(this.urlTwitter+'?url='+this.url+'&'+this.getCallbackUrlParameter(callback), callback);
	}
	
	/**
	 * Get share data from LinkedIn as an object. Object contains all data received from LinkedIn.
	 * @param {requestCallback} callback - callback for response, 1 parameter, example: myFunction(result).
	 */		
	SocialMediaStats.prototype.linkedin = function(callback) {
		this.getJsonp(this.urlLinkedIn+'?url='+this.url+'&'+this.getCallbackUrlParameter(callback), callback);
	}
	
	/**
	 * Inserts share count from Facebook into an element.
	 * @param {string} elementId - ID of element where result will be placed.
	 */
	SocialMediaStats.prototype.facebookCount = function(elementId) {
		var callbackName=this.createCallbackFunction(elementId, true);
		this.getJson(this.urlFacebook+'?id='+this.url, this.getJsonCallback, window[callbackName]);
	}

	/**
	 * Inserts share count from Twitter into an element.
	 * @param {string} elementId - ID of element where result will be placed.
	 */	
	SocialMediaStats.prototype.twitterCount = function(elementId) {
		var callbackName=this.createCallbackFunction(elementId, false);
		this.getJsonp(this.urlTwitter+'?url='+this.url+'&callback='+callbackName);
	}
	
	/**
	 * Inserts share count from LinkedIn into an element.
	 * @param {string} elementId - ID of element where result will be placed.
	 */		
	SocialMediaStats.prototype.linkedinCount = function(elementId) {
		var callbackName=this.createCallbackFunction(elementId, false);
		this.getJsonp(this.urlLinkedIn+'?url='+this.url+'&callback='+callbackName);
	}	
	
	/**
	 * @private
	 */
	SocialMediaStats.prototype.getJsonp = function(url) {
		var script=document.createElement('script');
		script.type='text/javascript';
		script.src=url;
		document.getElementsByTagName('head')[0].appendChild(script);
	}
	
	/**
	 * @private
	 */	
	SocialMediaStats.prototype.getJson = function(url, callbackInternal, callbackExternal) {
		var xmlhttp = new XMLHttpRequest();
		
		xmlhttp.onreadystatechange=function() {
			if (xmlhttp.readyState==4 && xmlhttp.status==200)
			callbackInternal(xmlhttp.responseText, callbackExternal);
		}
		
		xmlhttp.open("GET",url,true);
		xmlhttp.send();
	}
	
	/**
	 * @private
	 */
	SocialMediaStats.prototype.getJsonCallback = function(result, callback) {
		var parsedJson='';
		if(typeof JSON.parse === 'function') {
			parsedJson = JSON.parse(result);
		}
		else {
			parsedJson = eval ("("+result+")");
		}
		
		callback(parsedJson);
	}
	
	/**
	 * @private
	 */
	SocialMediaStats.prototype.getCallbackUrlParameter = function(functionReference) {
		return 'callback='+this.getFunctionName(functionReference);
	}
	
	/**
	 * @private
	 */
	SocialMediaStats.prototype.getFunctionName = function(functionReference) {
		var name=functionReference.toString();
		var reg=/function ([^\(]*)/;
		return reg.exec(name)[1];
	}
	
	/**
	 * @private
	 */
	SocialMediaStats.prototype.createCallbackFunction = function(elementId, isFacebook) {
		var callbackName=elementId+Math.floor(Math.random() * 100000);
		window[callbackName] = function(result) {
			if(isFacebook) {
				document.getElementById(elementId).innerHTML=(typeof result.shares==='undefined'?0:result.shares);
			}
			else
				document.getElementById(elementId).innerHTML=result.count;
			delete window[callbackName];
		}
		return callbackName;
	}	

}