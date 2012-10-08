class OvertimeStatesController < ApplicationController
  # GET /overtime_states
  # GET /overtime_states.json
  def index
    @overtime_states = OvertimeState.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @overtime_states }
    end
  end

  # GET /overtime_states/1
  # GET /overtime_states/1.json
  def show
    @overtime_state = OvertimeState.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @overtime_state }
    end
  end

  # GET /overtime_states/new
  # GET /overtime_states/new.json
  def new
    @overtime_state = OvertimeState.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @overtime_state }
    end
  end

  # GET /overtime_states/1/edit
  def edit
    @overtime_state = OvertimeState.find(params[:id])
  end

  # POST /overtime_states
  # POST /overtime_states.json
  def create
    @overtime_state = OvertimeState.new(params[:overtime_state])

    respond_to do |format|
      if @overtime_state.save
        format.html { redirect_to @overtime_state, notice: 'Overtime state was successfully created.' }
        format.json { render json: @overtime_state, status: :created, location: @overtime_state }
      else
        format.html { render action: "new" }
        format.json { render json: @overtime_state.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /overtime_states/1
  # PUT /overtime_states/1.json
  def update
    @overtime_state = OvertimeState.find(params[:id])

    respond_to do |format|
      if @overtime_state.update_attributes(params[:overtime_state])
        format.html { redirect_to @overtime_state, notice: 'Overtime state was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @overtime_state.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /overtime_states/1
  # DELETE /overtime_states/1.json
  def destroy
    @overtime_state = OvertimeState.find(params[:id])
    @overtime_state.destroy

    respond_to do |format|
      format.html { redirect_to overtime_states_url }
      format.json { head :no_content }
    end
  end
end
