#require "numru/netcdf"

class WorkflowsController < ApplicationController
  # GET /workflows
  # GET /workflows.json
  def index
    @workflows = Workflow.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @workflows }
    end
  end

  # GET /workflows/1
  # GET /workflows/1.json
  def show
    @workflow = Workflow.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @workflow }
    end
  end
  
  def create_config_input
    @ecosystems = params[:ecosystems]
  
  
  end

  # accepts a longitude, latitude:
    # http://localhost:3000/get_biome?lng=-89.25&lat=41.75
    # OR
    # $.post("get_biome", { lng: 106, lat: 127 });
  # returns JSON object of the biome
  def get_biome

    @biome_data = JSON.parse('{"native_eco":{},"agroecosystem_eco":{"springwheat":{"category":{"s000":"biofuels"},"T_A":{"s000":100},"T_E":{"s000":50},"r":{"s000":0},"OM_ag":{"s000":5.36},"OM_root":{"s000":12.9},"OM_wood":{"s000":0},"OM_litter":{"s000":10.5},"OM_peat":{"s000":0},"OM_SOM":{"s000":0},"fc_ag_wood_litter":{"s000":0},"fc_root":{"s000":0},"fc_peat":{"s000":0},"fc_SOM":{"s000":0},"Ec_CO2":{"s000":34.43182},"Ec_CH4":{"s000":0.16875},"Ec_N2O":{"s000":0.001591},"k_ag_wood_litter":{"s000":0.4},"k_root":{"s000":0.4},"k_peat":{"s000":0},"k_SOM":{"s000":0.4},"termite":{"s000":0},"Ed_CO2_ag_wood_litter":{"s000":41.66667},"Ed_CO2_root":{"s000":41.66667},"Ed_CO2_peat":{"s000":45},"Ed_CO2_litter":{"s000":48.33333},"Ed_CH4_ag_wood_litter":{"s000":0},"Ed_CH4_root":{"s000":0},"Ed_CH4_peat":{"s000":0},"Ed_CH4_litter":{"s000":0},"Ed_N2O_ag_wood_litter":{"s000":0},"Ed_N2O_root":{"s000":0},"Ed_N2O_peat":{"s000":0},"Ed_N2O_litter":{"s000":0},"F_CO2":{"s000":-0.56667},"F_CH4":{"s000":-0.12547},"F_N2O":{"s000":0.045302},"rd":{"s000":0},"tR":{"s000":-9999},"FR_CO2":{"s000":-9999},"FR_CH4":{"s000":-9999},"FR_N2O":{"s000":-9999},"dfc_ag_wood_litter":{"s000":-9999},"dfc_root":{"s000":0},"dfc_peat":{"s000":0},"dk_ag_wood_litter":{"s000":0.4},"dk_root":{"s000":0.4},"dk_peat":{"s000":0},"age_transition":{"s000":-9999},"new_F_CO2":{"s000":-9999},"new_F_CH4":{"s000":-9999},"new_F_N2O":{"s000":-9999},"F_anth":{"s000":14.71212}}},"aggrading_eco":{},"biofuel_eco":{}}')
    
    respond_to do |format|
      format.json { render json: @biome_data }
    end

  end

  # GET /workflows/new
  # GET /workflows/new.json
  def new
    @workflow = Workflow.new
    # open data/default_ecosystems.json and parse
    # object returned is an array of hashes... Ex:
    # p @ecosystems[0] # will return a Hash
    # p @ecosystems[0]["category"] # => "native"
    @ecosystems = JSON.parse( File.open( "#{Rails.root}/data/default_ecosystems.json" , "r" ).read )
    @name_indexed_ecosystems = JSON.parse( File.open( "#{Rails.root}/data/name_indexed_ecosystems.json" , "r" ).read )
    @ecosystem = @ecosystems[0]

# This is where I'll open the Priors from the DB    
#    @priors = Prior.all
# A prior will have a number of variables
# One of those variables can belong to a given citation

# A PFT would be akin to an ecosystem 
#render :partial => "my_partial", :locals => {:player => Player.new}


    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @workflow }
    end
  end

  # GET /workflows/1/edit
  def edit
    @workflow = Workflow.find(params[:id])
  end

  # POST /workflows
  # POST /workflows.json
  def create
    @workflow = Workflow.new(params[:workflow])

    respond_to do |format|
      if @workflow.save
        format.html { redirect_to @workflow, notice: 'Workflow was successfully created.' }
        format.json { render json: @workflow, status: :created, location: @workflow }
      else
        format.html { render action: "new" }
        format.json { render json: @workflow.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /workflows/1
  # PUT /workflows/1.json
  def update
    @workflow = Workflow.find(params[:id])

    respond_to do |format|
      if @workflow.update_attributes(params[:workflow])
        format.html { redirect_to @workflow, notice: 'Workflow was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @workflow.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /workflows/1
  # DELETE /workflows/1.json
  def destroy
    @workflow = Workflow.find(params[:id])
    @workflow.destroy

    respond_to do |format|
      format.html { redirect_to workflows_url }
      format.json { head :no_content }
    end
  end
end
