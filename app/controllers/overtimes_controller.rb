#!/usr/bin/env ruby
# -*- coding:utf-8 -*-

class OvertimesController < ApplicationController
  
  before_filter :authenticate_user!
  
  # GET /overtimes
  # GET /overtimes.json
  def index
    @title = '加班'
    filter = 'all'
    
    # not applyed
    revoke_state = OvertimeState.find_by_code('Revoke')
    reject_state = OvertimeState.find_by_code('Reject')
    # approved
    approved_state = OvertimeState.find_by_code('Approved')
    
    start_time, end_time, date_filter = Time.now-1.year, Time.now+1.year, ''
    
    if current_user.is_hr?
      # applications = Application.objects.all()
      @overtimes = {
        'all' => Overtime.scoped,
        'new' => Overtime.where(:state => [revoke_state, reject_state]),
        'applying' => Overtime.where(:state => [revoke_state, reject_state, approved_state]),
        'approved' => Overtime.where(:state => approved_state),
        }[filter]
      @overtimes = @overtimes.where(:created_at => start_time..end_time).order('updated_at DESC')
    else
      @overtime_flows = {
        'all' => current_user.overtime_flows.scoped,
        'new' => current_user.overtime_flows.joins(:overtime).where('overtimes.state_id' => [revoke_state, reject_state]),
        'applying' => current_user.overtime_flows.joins(:overtime).where('overtimes.state_id' => [revoke_state, reject_state, approved_state]),
        'approved' => current_user.overtime_flows.joins(:overtime).where('overtimes.state_id' => approved_state),
        }[filter]
      @overtime_flows = @overtime_flows.joins(:overtime).where('overtimes.created_at' => start_time..end_time).order('updated_at DESC')
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @overtimes }
    end
  end

  # GET /overtimes/1
  # GET /overtimes/1.json
  def show
    @overtime = Overtime.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @overtime }
    end
  end

  # GET /overtimes/new
  # GET /overtimes/new.json
  def new
    @title = '新增加班'
    @overtime = Overtime.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @overtime }
    end
  end

  # GET /overtimes/1/edit
  def edit
    @overtime = Overtime.find(params[:id])
  end

  # POST /overtimes
  # POST /overtimes.json
  def create
    next_user = Overtime.create_with_flow(current_user, params[:overtime])

    respond_to do |format|
      if @overtime.save
        format.html { redirect_to @overtime, notice: 'Overtime was successfully created.' }
        format.json { render json: @overtime, status: :created, location: @overtime }
      else
        format.html { render action: "new" }
        format.json { render json: @overtime.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /overtimes/1
  # PUT /overtimes/1.json
  def update
    @overtime = Overtime.find(params[:id])

    respond_to do |format|
      if @overtime.update_attributes(params[:overtime])
        format.html { redirect_to @overtime, notice: 'Overtime was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @overtime.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /overtimes/1
  # DELETE /overtimes/1.json
  def destroy
    @overtime = Overtime.find(params[:id])
    @overtime.destroy

    respond_to do |format|
      format.html { redirect_to overtimes_url }
      format.json { head :no_content }
    end
  end
end
