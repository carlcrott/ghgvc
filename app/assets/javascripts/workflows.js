var id_seed = 0;
function generate_id() { return id_seed++; };

function remove_google_maps_pin( biome_site_id ) {
  if ( markersArray[biome_site_id] != undefined ) { markersArray[biome_site_id].setMap(null) };
};

function activate_biome_location( obj ) {
    collapse_all_ecosystem_wells();
    obj.find('.remove_biome_site').show();
    $('label.checkbox').find('input').removeAttr("disabled");
    
    obj.removeClass('inactive_site');
    obj.find('input').show();
    obj.find('label').show();
    obj.find('a').show();
    // effectively cuts and pastes the obj to the top of the biome_input_container
    obj.prependTo("#biome_input_container");
};


// Called everytime a user clicks on google maps
// Handles whether to keep a given marker at a lat/lng or remove it
function place_google_maps_pin( lat, lng, biome_site_id ) {
  // remove any markers tied to a biome_site_id
  remove_google_maps_pin(biome_site_id);

  // generate a new marker
  var marker = new google.maps.Marker({ position: new google.maps.LatLng( lat , lng ) });
  // push the marker into the storage array
  markersArray[biome_site_id] = marker;
  
  // Add listener to activate a biome location on clicking the corresponding map marker
  google.maps.event.addListener( markersArray[biome_site_id], 'click', function() {
    activate_biome_location( $('#biome_instance-' + biome_site_id) );
  });
  
  return marker
};

function get_active_site_number() {
  // find the first div#biome_instance without .inactive_site ... and grab the id number
  return $('div[id|="biome_instance"]:not(inactive_site)').attr('id').split('-').pop()
};

function populate_html_from_latlng( lat, lng ) {

  $.get("/get_biome", { lng: Math.round(lng), lat: Math.round(lat) }, function(data) {
    var active_biome_site = get_active_site_number();

    $('#biome_instance-' + active_biome_site ).prepend( // used for default values in popups
      '<div class="json_store">' + 
        JSON.stringify(data) + // stringify will work with IE8
      '</div>'
    );

    var data_defaults = data;

    // write default values to all CSEPs
    if ( data_defaults.native_eco != null ) {
      $.each( data_defaults.native_eco, function( k, v ) { // ecosystems
        $.each( data_defaults.native_eco[k] , function( csep_k, csep_v ){ // CSEPs
          data_defaults.native_eco[k][csep_k] = { "Anderson-Teixeira and DeLucia (2011)" : csep_v.s000 };
        });
      });
    };
    if ( data_defaults.agroecosystem_eco != null ) {
      $.each( data_defaults.agroecosystem_eco, function( k, v ) { // ecosystems
        $.each( data_defaults.agroecosystem_eco[k] , function( csep_k, csep_v ){ // CSEPs
          data_defaults.agroecosystem_eco[k][csep_k] = { "Anderson-Teixeira and DeLucia (2011)" : csep_v.s000 };
        });
      })
    };
    if ( data_defaults.aggrading_eco != null ) {
      $.each( data_defaults.aggrading_eco, function( k, v ) { // ecosystems
        $.each( data_defaults.aggrading_eco[k] , function( csep_k, csep_v ){ // CSEPs
          data_defaults.aggrading_eco[k][csep_k] = { "Anderson-Teixeira and DeLucia (2011)" : csep_v.s000 };
        });
      });
    };  
    if ( data_defaults.biofuel_eco != null ) {
     $.each( data_defaults.biofuel_eco, function( k, v ) { // ecosystems
        $.each( data_defaults.biofuel_eco[k] , function( csep_k, csep_v ){ // CSEPs
          data_defaults.biofuel_eco[k][csep_k] = { "Anderson-Teixeira and DeLucia (2011)" : csep_v.s000 };
        });
      });
    };



    $('#biome_instance-' + active_biome_site ).append( // used to store the values the user has selected
      '<div class="json_saved">' + 
        JSON.stringify(data_defaults) + // stringify will work with IE8
      '</div>'
    ).append( // used for inputs into the ghgvcR code
      '<div class="json_final">' + 
        JSON.stringify(data_defaults) +
      '</div>'
    );

    
    marker = place_google_maps_pin( lat, lng, active_biome_site );
    marker.setMap(map); // To add the marker to the map, call setMap();

    // Tag the site w the given lat and lng
    $('div.well:not(.inactive_site)').find('.site_latlng').text("( "+ lat.toFixed(2) + ", " + lng.toFixed(2) + " )");

    if ( data.native_eco != null ) {
      $.each( data.native_eco, function(k,v) {
        $('div.well:not(.inactive_site)').find('.native_biomes').find('.biome_list').append(
          '<div class="biome_match">' +
            '<label class="checkbox inline-block"><input type="checkbox" class="inline-block">' + k.replace("_"," ") + '</input></label>' +
            '<a class="edit_icon_link" data-toggle="lightbox" href="#ecosystem_popup">' + 
              '<i class="icon-search icon-list-alt inline-block edit_icon" rel="tooltip" title="edit"></i>' + 
            '</a>' + 
          '</div>'
        ).parent().css("height", "auto");
        // Could add delegate option here to show / hide the EDIT icon on checking the checkbox
      });
    };
    
    if ( data.biofuel_eco != null ) {
      $.each( data.biofuel_eco, function(k,v) {
        $('div.well:not(.inactive_site)').find('.biofuel_biomes').find('.biome_list').append(
          '<div class="biome_match">' +
            '<label class="checkbox inline-block"><input type="checkbox" class="inline-block">' + k.replace("_"," ") + '</input></label>' +
            '<a class="edit_icon_link" data-toggle="lightbox" href="#ecosystem_popup">' + 
              '<i class="icon-search icon-list-alt inline-block edit_icon" rel="tooltip" title="edit"></i>' + 
            '</a>' + 
          '</div>'
        ).parent().css("height", "auto");
        // Could add delegate option here to show / hide the EDIT icon on checking the checkbox
      });
    };

    if ( data.agroecosystem_eco != null ) {
      $.each( data.agroecosystem_eco, function(k,v) { 
        $('div.well:not(.inactive_site)').find('.agroecosystem_biomes').find('.biome_list').append(
          '<div class="biome_match">' +
            '<label class="checkbox inline-block"><input type="checkbox" class="inline-block">' + k.replace("_"," ") + '</input></label>' +
            '<a class="edit_icon_link" data-toggle="lightbox" href="#ecosystem_popup">' + 
              '<i class="icon-search icon-list-alt inline-block edit_icon" rel="tooltip" title="edit"></i>' + 
            '</a>' + 
          '</div>'
        ).parent().css("height", "auto");
        // Could add delegate option here to show / hide the EDIT icon on checking the checkbox
      });
    };
   

  });
};


function initalize_google_map(lat, lng, zoom) {
  var type = $(document).find('.map_type_selector.active').html().toLowerCase();

  var minZoomLevel = 2;
  var geocoder;
  var address;
  var latlng = new google.maps.LatLng(31,-15);
  var myOptions = {
    zoom: minZoomLevel,
    streetViewControl: false,
    mapTypeControl: false,
    panControl: false,
    center: latlng,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  };
  var overlayOptions = {
    opacity: 0.6,
  }

  // Google coordinate plane increases in the positive number direction left to right
  map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);

  // setup of globalbiomes map  
  var globalbiomes_bounds = new google.maps.LatLngBounds(
    new google.maps.LatLng(-92,-179 ), // south-west
    new google.maps.LatLng(84.8,178.7) // north-east
  );
  var globalbiomes = new google.maps.GroundOverlay( '../globalbiomes_overlay.png', globalbiomes_bounds, overlayOptions);
  // setup of vegtype map  
  var vegtype_bounds = new google.maps.LatLngBounds(
    new google.maps.LatLng(-59,-176.8), // south-west
    new google.maps.LatLng(84,179) // north-east
//        new google.maps.LatLng(-50,-124.8), // south-west
//        new google.maps.LatLng(80,115) // north-east  

  );
  var vegtype = new google.maps.GroundOverlay( '../vegtype_overlay.png', vegtype_bounds, overlayOptions );
  window.vegtype = vegtype; // TODO: remove this after we find out the way to trigger click event correctly
 
  // clear out existing biome matches
  //$('div[id*="_biomes"]').hide();
  $('div[id*="_biomes"]').find('.biomes').html("");
  
  if (type == "vegtype" ) {
    vegtype.setMap(map);
  } else if (type == "globalbiomes" ) {
    globalbiomes.setMap(map);
  } else {
    // no map overlay
  }
  
  //overlay = [];
  
  // Bounds for A single map
   var strictBounds = new google.maps.LatLngBounds(
     new google.maps.LatLng(-70, -170), // bottom-left
     new google.maps.LatLng(70, 170)   // top-right
   );

   // Listen for the map click events
   google.maps.event.addListener(map, 'dragend', function() {
     if (strictBounds.contains(map.getCenter())) return;

     // We're out of bounds - Move the map back within the bounds
     var c = map.getCenter(),
         x = c.lng(),
         y = c.lat(),
         maxX = strictBounds.getNorthEast().lng(),
         maxY = strictBounds.getNorthEast().lat(),
         minX = strictBounds.getSouthWest().lng(),
         minY = strictBounds.getSouthWest().lat();

     if (x < minX) x = minX;
     if (x > maxX) x = maxX;
     if (y < minY) y = minY;
     if (y > maxY) y = maxY;

     map.setCenter(new google.maps.LatLng(y, x));
   });

  // Limit the zoom level
  google.maps.event.addListener(map, 'zoom_changed', function() {
    if (map.getZoom() < minZoomLevel) map.setZoom(minZoomLevel);
  });
  
  markersArray = [];
  google.maps.event.addListener(vegtype, "click", function(event) {

    var lat = event.latLng.lat();
    var lng = event.latLng.lng();

    // clear out existing biome matches
    $('#biome_input_container').find('div.well:not(.inactive_site)').find('div[class*="_biomes"]').find('.biome_list').html("");

    populate_html_from_latlng( lat, lng );

    // for offline testing
    // populate_html_from_latlng( 39.16113, -4.978971 );
    
  });
};

// This function swaps out the abbreviated data source names
// for the full names: "s000" = "Anderson-Teixeira and DeLucia (2011)" 
// Expecting input formatted as:
// {"s000":234,"s001":9992}
function populate_fullname_in_data_source( csep_value ) {

  $.each( csep_value, function( sources_key, sources_value) {
    switch ( sources_key ) { 
      case "s000": 
        csep_value["Anderson-Teixeira and DeLucia (2011)"] = sources_value;
        delete csep_value.s000
        break;
      case "s001": 
        csep_value["Saatchi and others (2011)"] = sources_value;
        delete csep_value.s001
        break; 
    }
  });
  return csep_value;
};

function populate_ecosystem_shadowbox( site_id, biome_type, biome_name ) {
  $("#ecosystem_popup").find(".lightbox-content").each(function() {
    $(this).find(".popup_heading").text( biome_type + ": " + biome_name.replace("_", " ") );

    // get the ecosystems from that biome_instance
    var ecosystems = $.parseJSON( $('#biome_instance-' + site_id).find('.json_saved').text() );

    // with all data sources ( EX: "s001" )
    var current_ecosystem = ecosystems[biome_type + "_eco"][biome_name.replace(" ", "_")];

    // Clear out all existing drop-down values
    $('.popup_cite_dropdown').empty();
   
    // For the current_ecosystem ( EX: "miscanthus" )
    $.each( current_ecosystem, function( csep_key, csep_value ) {
      // Find the row corresponding to a CSEP value ( EX: "OM_ag")
      $.each( $('#ecosystem_edit').find('tr#' + csep_key), function() {
        var csep_row = $(this);
        
        // Since we've got place holders for the source names such as "s000"
        // Instead of the desired "Anderson-Teixeira and DeLucia (2011)"
        csep_value = populate_fullname_in_data_source(csep_value);

        // if a custom field doesn't exist ... add it in
        if ( csep_value['custom'] == null ) {
          csep_value['custom'] = 'custom';
        };

        // Finally the value of each CSEP is a hash
        // which contains multiple data sources
        // loop through those sources and place them within the dropdown
        $.each( csep_value, function( sources_key, sources_value ) {
          // populate in the saved values, or default values from json_saved
          // place in the other options from json_store
          csep_row.find('.popup_cite_dropdown').append( $("<option></option>").attr("value", sources_value).text(sources_key) );
        });
        
      });
    });
    
    // At this point all values are populated in
    // Next we need to display the values the user has selected ( the values that are present in the .json_saved )
    // ... which could be default values, or those that the user has saved )
    
    var user_saved_ecosystems = $.parseJSON( $('#biome_instance-' + site_id).find('.json_saved').text() );
    var user_saved_current_ecosystem = user_saved_ecosystems[biome_type + "_eco"][biome_name.replace(" ", "_")];
    
    console.log("filling popup with: ");
    console.log(user_saved_current_ecosystem);
    
    $.each( user_saved_current_ecosystem, function( csep_key, csep_value ) {
      // Find the row corresponding to a CSEP value ( EX: "OM_ag")
      $.each( $('#ecosystem_edit').find('tr#' + csep_key), function() {
        var csep_row = $(this);

        // Each CSEP will have a value saved in the users json_saved
        // So we iterate through the json_saved
        // And set the dropdown for that CSEP to the value in json_saved
        
        // Create a array with the single K and V from the CSEP within .json_saved
        // then select the "key" or Array[0] to feed into the selected value below

        $.each(csep_value, function (index, value) {
          saved_csep_values = [index, value];
        });
        csep_row.find( csep_key + '-source').val( saved_csep_values[0] ); // the 0 index will contain the source 
        csep_row.find('#ecosystem_' + csep_key ).val( saved_csep_values[1] ); // the 0 index will contain the source         
        
      });
    });

  });
};

function open_previous_biome_site() {
  $('#biome_input_container').find('div.well').first().removeClass('inactive_site');
};

function collapse_all_ecosystem_wells() {
  $('#biome_input_container').find('div.well').addClass('inactive_site');
  $('#biome_input_container').find('.remove_biome_site').hide();
  $('#biome_input_container').find('div.well').find('label.checkbox').each( function() {
    if ( $(this).find('input').is(':checked') == false ) {
      // hide the label and checkbox
      $(this).hide();
      // hide associated edit icon
      $(this).siblings('a').hide();
      
    }
  });
};


function get_selected_ecosystems_name_and_type( location ) {
  var ecosystems_at_this_location = location.find('label.checkbox');
  
  var selected_ecosystem_names = [];
  
  // Iterate through the checkboxes associated with the ecosystem names
  // And if they're checked ... add them to the selected_ecosystem_names
  $.each( ecosystems_at_this_location, function() {
    if ( $(this).find('input').is(':checked') ) {
      var ecosystem_type = $(this).closest("[class*='_biomes']").attr("class").split(" ")[0].split("_")[0];
      var ecosystem_name = $(this).text();
      selected_ecosystem_names.push( [ ecosystem_type, ecosystem_name ] );
    }; 
  });
  return selected_ecosystem_names;    
};

$(document).ready(function() {
  initalize_google_map();
  
  $('#run_ghgvc_calculator').on('click' ,function() {
    // deactivate or put the page on hold
    // run the stuff to init the calculator

    ghgvcR_input = {};

    var all_locations = $('[id|="biome_instance"]');
    var all_input_ecosystems = $('[id|="biome_instance"]').find('.json_saved');
    
    $.each( all_locations, function() {
    
      // go through each location
      var biome_group =  $(this);
      var ecosystem_to_include = get_selected_ecosystems_name_and_type( $(this) );
      var current_biomes_json = $.parseJSON( biome_group.find('.json_saved').text() );
      console.log("current_biomes_json");
      console.log(current_biomes_json);
      
      $.each( ecosystem_to_include, function(i,v){
        // and each ecosystem

        var input_ecosystem_json = current_biomes_json[v[0] + "_eco"][v[1].replace(" ","_")];
        console.log( input_ecosystem_json );
        var biome_group_string = biome_group.attr('id');
        var biome_type_string = v[0] + "_eco";
        var biome_name_string = v[1].replace(" ","_");
        
        // if keys dont exist ... add them
        if (!( biome_group_string in ghgvcR_input ))  ghgvcR_input[biome_group_string] = {};
        if (!( biome_type_string in ghgvcR_input[biome_group_string] ))  ghgvcR_input[biome_group_string][biome_type_string] = {};
        
        ghgvcR_input[biome_group_string][biome_type_string][biome_name_string] = input_ecosystem_json;
        
      });
    });

    // At this point we've got the names of selected ecosystems at each location
    console.log("ghgvcR_input");    
    console.log( ghgvcR_input );    

  });
  

  $('.popup_cite_dropdown').change( function() {
    // Assign the selected value in the drop down, to the subling input box
    $(this).parentsUntil('tbody').find('.popup_value_field').val( $(this).val() );
  });
  $('.popup_value_field').on('focus', function() {
    // Assign the selected value in the drop down, to the subling input box
    $(this).parentsUntil('tbody').find('.popup_cite_dropdown').val("custom");
  });
  
  
  $("#popup_save_ecosystem_modifications").on('click', function() {
    // get all fields / values
//    console.log( $('#ecosystem_edit').find('.popup_value_field') );
    var ecosystem_type_being_saved = $('#ecosystem_edit').find('.popup_heading').text().split(":")[0] + "_eco";
    var ecosystem_being_saved = $('#ecosystem_edit').find('.popup_heading').text().split(":")[1].trim().replace(" ","_");    
    var active_site_num = get_active_site_number();
    var all_ecosystems_at_site = $.parseJSON( $('#biome_instance-' + active_site_num ).find('.json_saved').text() );

    var ecosystem = all_ecosystems_at_site[ecosystem_type_being_saved][ecosystem_being_saved]

    // while in the popup
    // discard custom values... if the ecosystem is saved with one of the default values
    
    // then when populating the edit_popup ... if a ['custom'] exists .. use it as the default

    
    $.each( ecosystem , function( csep_k, csep_v ){
      // find associated CSEP value and store whats in the .popup_value_field
      var save_csep_source = $("#" + csep_k + "-source option:selected").text();
      var save_csep_value = $("#ecosystem_" + csep_k).val();
      
      ecosystem[csep_k] = {};
      ecosystem[csep_k][save_csep_source] = save_csep_value;
//      console.log("Wrote out: " + csep_k + " as: " + save_csep_source +":"+save_csep_value);
    });

    // At this point the ecosystem object will contain *ONLY* a single key/value pair ( source / value pair )
    console.log("This is what was saved:");
    console.log(ecosystem);


    // Finally write out the saved JSON
    $('#biome_instance-' + active_site_num ).find('.json_saved').text( JSON.stringify( all_ecosystems_at_site ) );
    
    // This will hit the hidden close button and invoke the close operation in bootstrap-lightbox
    $("#hidden_close_button").trigger("click");
  });
  
  $("#popup_discard_ecosystem_modifications").on('click', function() {
    // This will hit the hidden close button and invoke the close operation in bootstrap-lightbox
    $("#hidden_close_button").trigger("click");
  });
  
  $("#biome_input_container").delegate('.edit_icon', "click" , function() {
    var site_id = $(this).closest('[id]|="biome_instance"').attr("id").split("-")[1]
    var biome_name = $(this).closest(".biome_match").find("label.checkbox").text();
    var biome_type = $(this).closest("[class*='_biomes']").attr("class").split(" ")[0].split("_")[0]
    populate_ecosystem_shadowbox( site_id, biome_type, biome_name );
  });

  $('#add_additional_biome_site').on('click', function() {
    collapse_all_ecosystem_wells();

    // Add in new biome site, which will be ACTIVE 
    $('#biome_input_container').prepend(
      '<div id="biome_instance-' + generate_id() + '" class="well well-small collapsed">' +
      '  <div class="biome_site_header inline-block"><h4>Location Lat/Lng: <span class="site_latlng">( -- , -- )</span></h4></div>' + 
      '  <div class="remove_biome_site btn btn-small btn-danger inline-block pull-right">' + 
      '    <i class="icon-search icon-remove"></i> Remove Location' +
      '  </div>' + '  <br />' + '<hr/>' +
      '  <div class="native_biomes inline-block">' + '    <b>Native:</b>' + '    <div class="biome_list"></div>' + '  </div>' +
      '  <div class="aggrading_biomes inline-block">' + '    <b>Aggrading:</b>' + '    <div class="biome_list"></div>' + '  </div>' +
      '  <div class="agroecosystem_biomes inline-block">' + '    <b>Agroecosystem:</b>' + '    <div class="biome_list"></div>' + '  </div>' +
      '  <div class="biofuel_biomes inline-block">' + '    <b>Biofuel:</b>' + '    <div class="biome_list"></div>' + '  </div>' +
      '</div>'
    ).delegate(".remove_biome_site", "click", function() {
      remove_google_maps_pin( $(this).parent().attr('id').split('-').pop() );
      $(this).parent().remove();
      open_previous_biome_site();
    });
    

     
  
  });
  // Add inital biome list using above code:
  $('#add_additional_biome_site').trigger('click');

  
  // handles reactivating a site when selected
  $('#biome_input_container').on("click", ".inactive_site" , function() {
    activate_biome_location( $(this) );
  });

  $(".biome_list").tooltip({
    'selector': 'i',
    'placement': 'right'
  });

  $('.map_type_selector').on('click', function() {
    $(document).find('.map_type_selector').removeClass('active');
    $(this).addClass('active');
    
    // clear out existing biome matches
    $('div[id*="_biomes"]').hide();
    $('div[id*="_biomes"]').find('.biomes').html("");
  
    console.log(map.getZoom());
    console.log("lat: " + map.getCenter().lat() );
    console.log("lng: " + map.getCenter().lng() );
    
    initalize_google_map();
  });
  
});
