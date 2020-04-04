/**
 * EventON Generate Google Maps Function
 * @version  0.2
 */
(function($){
	$.fn.evoGenmaps = function(opt){
		
		var defaults = {
			delay:	0,
			fnt:	1,
			cal:	'',
			mapSpotId:	'',
			_action:''
		};
		var options = $.extend({}, defaults, opt); 
		
		var geocoder;


		// popup lightbox generation
			if(options._action=='lightbox'){
				loadl_gmaps_in(this, options.cal, options.mapSpotId);
			}

		// functions
			if(options.fnt==1){
				this.each(function(){
					var eventcard = $(this).attr('eventcard');
				
					if(eventcard=='1'){
						$(this).find('a.desc_trig').each(function(elm){
							//$(this).siblings('.event_description').slideDown();
							var obj = $(this);
							
							if(options.delay==0){
								load_googlemaps_here(obj);
							}else{
								setTimeout(load_googlemaps_here, options.delay, obj);
							}
						});
					}
				});
			}
			
			if(options.fnt==2){
				if(options.delay==0){
					load_googlemaps_here(this);
				}else{
					setTimeout(load_googlemaps_here, options.delay, this);
				}					
			}
			if(options.fnt==3){
				loadl_gmaps_in(this, options.cal, '');			
			}
			
			// gmaps on popup
			if(options.fnt==4){
				// check if gmaps should run
				if( this.attr('data-gmtrig')=='1' && this.attr('data-gmap_status')!='null'){				
					var cal = this.closest('div.ajde_evcal_calendar ');
					loadl_gmaps_in(this, cal, options.mapSpotId);
				}	
			}	
		
		// function to load google maps for eventcard
		function load_googlemaps_here(obj){
			if( obj.data('gmstat')!= '1'){				
				obj.attr({'data-gmstat':'1'});
			}
			
			var cal = obj.closest('div.ajde_evcal_calendar ');
			
			if( obj.attr('data-gmtrig')=='1' && obj.attr('data-gmap_status')!='null'){
				loadl_gmaps_in(obj, cal, '');				
			}	
		}		
		
		// Load the google map on the object
		function loadl_gmaps_in(obj, cal, mapId){

			var evodata = cal.find('.evo-data');

			var mapformat = evodata.data('mapformat');				
			var ev_location = obj.find('.evcal_desc');

			var location_type = ev_location.attr('data-location_type');
			if(location_type=='address'){
				var address = ev_location.attr('data-location_address');
				var location_type = 'add';
			}else{			
				var address = ev_location.attr('data-latlng');
				var location_type = 'latlng';				
			}

			var map_canvas_id= (mapId!=='')?
				mapId:
				obj.closest('.eventon_list_event').find('.event_description').find('.evcal_gmaps').attr('id');				
				
			// google maps styles
			// @since 2.2.22
			var styles = '';

			if( typeof gmapstyles !== 'undefined' && gmapstyles != 'default'){
				styles = $.parseJSON(gmapstyles);
			}

			var zoom = evodata.data('mapzoom');
			var zoomlevel = (typeof zoom !== 'undefined' && zoom !== false)? parseInt(zoom):12;
			
			var scroll = evodata.data('mapscroll');	
			//console.log(map_canvas_id+' '+mapformat+' '+ location_type +' '+scroll +' '+ address);			
								
			//obj.siblings('.event_description').find('.evcal_gmaps').html(address);
			if($('#'+map_canvas_id).length>0)
				initialize(
					map_canvas_id, 
					address, 
					mapformat, 
					zoomlevel, 
					location_type, 
					scroll, 
					styles,
					evodata.attr('data-mapiconurl')
				);
		}
		
		//console.log(options);
		
	};
}(jQuery));