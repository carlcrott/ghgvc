#= require spec_helper
#= require google_maps

describe "clicking on the map", ->
  beforeEach ->
    page = $ document.body
    page.append '<button class="btn map_type_selector active">VEGTYPE</button>'
    page.append '<div id="map_canvas"></div>'
    page.append '<div id="biome_instance-0" class="well"><div class="agroecosystem_biomes"><div class="biome_list"></div></div></div>'
    initalize_google_map()
    @trigger = (lat, lng) ->
      google.maps.event.trigger vegtype, 'click', latLng:
        lat: -> lat
        lng: -> lng

  # TODO: this is just an example to make sure stubbing works
  it "calls populate function", ->
    stub = @sandbox.stub window, 'populate_html_from_latlng'
    @trigger 1, 2
    stub.should.have.been.calledWith 1, 2

  it "adds a match to the list", ->
    data = '{"native_eco":{},"agroecosystem_eco":{"springwheat":{"category":{"s000":"biofuels"},"T_A":{"s000":100},"T_E":{"s000":50},"r":{"s000":0},"OM_ag":{"s000":5.36},"OM_root":{"s000":12.9},"OM_wood":{"s000":0},"OM_litter":{"s000":10.5},"OM_peat":{"s000":0},"OM_SOM":{"s000":0},"fc_ag_wood_litter":{"s000":0},"fc_root":{"s000":0},"fc_peat":{"s000":0},"fc_SOM":{"s000":0},"Ec_CO2":{"s000":34.43182},"Ec_CH4":{"s000":0.16875},"Ec_N2O":{"s000":0.001591},"k_ag_wood_litter":{"s000":0.4},"k_root":{"s000":0.4},"k_peat":{"s000":0},"k_SOM":{"s000":0.4},"termite":{"s000":0},"Ed_CO2_ag_wood_litter":{"s000":41.66667},"Ed_CO2_root":{"s000":41.66667},"Ed_CO2_peat":{"s000":45},"Ed_CO2_litter":{"s000":48.33333},"Ed_CH4_ag_wood_litter":{"s000":0},"Ed_CH4_root":{"s000":0},"Ed_CH4_peat":{"s000":0},"Ed_CH4_litter":{"s000":0},"Ed_N2O_ag_wood_litter":{"s000":0},"Ed_N2O_root":{"s000":0},"Ed_N2O_peat":{"s000":0},"Ed_N2O_litter":{"s000":0},"F_CO2":{"s000":-0.56667},"F_CH4":{"s000":-0.12547},"F_N2O":{"s000":0.045302},"rd":{"s000":0},"tR":{"s000":-9999},"FR_CO2":{"s000":-9999},"FR_CH4":{"s000":-9999},"FR_N2O":{"s000":-9999},"dfc_ag_wood_litter":{"s000":-9999},"dfc_root":{"s000":0},"dfc_peat":{"s000":0},"dk_ag_wood_litter":{"s000":0.4},"dk_root":{"s000":0.4},"dk_peat":{"s000":0},"age_transition":{"s000":-9999},"new_F_CO2":{"s000":-9999},"new_F_CH4":{"s000":-9999},"new_F_N2O":{"s000":-9999},"F_anth":{"s000":14.71212}}},"aggrading_eco":{},"biofuel_eco":{}}'

    server = @sandbox.useFakeServer()
    @trigger 1, 2
    server.requests[0].respond 200, { "Content-Type": "application/json" }, data
    $('.biome_match').should.exist
