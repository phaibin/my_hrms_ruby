#!/usr/bin/env ruby
# -*- coding:utf-8 -*-

require 'csv'

class OvertimesController < ApplicationController
  
  before_filter :authenticate_user!
  
  # GET /overtimes
  # GET /overtimes.json
  def index
    @title = '加班'
    
    # not applyed
    revoke_state = OvertimeState.find_by_code('Revoke')
    reject_state = OvertimeState.find_by_code('Reject')
    # approved
    approved_state = OvertimeState.find_by_code('Approved')

    @state_filter = params['state'] || 'all'
    @quick_date_ranges = params['quickDateRanges'] || '7'
    @date_from = params['date_from']
    @date_to = params['date_to']
    @start_time, @end_time, @date_filter = self.get_date_filter(@quick_date_ranges)
    
    if current_user.is_hr?
      # applications = Application.objects.all()
      @overtimes = {
        'all' => Overtime.scoped,
        'new' => Overtime.where(:state => [revoke_state, reject_state]),
        'applying' => Overtime.where(["state_id not in (?)", [revoke_state, reject_state, approved_state]]),
        'approved' => Overtime.where(:state => approved_state),
        }[@state_filter]
      @overtimes = @overtimes.where(:created_at => @start_time..@end_time).order('updated_at DESC')
    else
      @overtime_flows = {
        'all' => current_user.overtime_flows.scoped,
        'new' => current_user.overtime_flows.joins(:overtime).where('overtimes.state_id' => [revoke_state, reject_state]),
        'applying' => current_user.overtime_flows.joins(:overtime).where(["state_id not in (?)", [revoke_state, reject_state, approved_state]]),
        'approved' => current_user.overtime_flows.joins(:overtime).where('overtimes.state_id' => approved_state),
        }[@state_filter]
      @overtime_flows = @overtime_flows.joins(:overtime).where('overtimes.created_at' => @start_time..@end_time).order('updated_at DESC')
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
    @overtime = Overtime.create_with_flow(current_user, params[:overtime])

    respond_to do |format|
      if @overtime
        format.html { redirect_to overtimes_path, notice: 'Overtime was successfully created.' }
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
      if @overtime.update_with_flow(current_user, params[:overtime])
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
  
  def revoke
    @overtime = Overtime.find(params[:id])
    @overtime.revoke(current_user)
    redirect_to overtimes_path
  end
  
  def apply
    @overtime = Overtime.find(params[:id])
    @overtime.apply(current_user)
    redirect_to overtimes_path
  end
  
  def overview
    @title = '加班统计'
    
    @quick_date_ranges = params['quickDateRanges'] || '7'
    @date_from = params['date_from']
    @date_to = params['date_to']
    @start_time, @end_time, @date_filter = self.get_date_filter(@quick_date_ranges)
    
    approved_state = OvertimeState.find_by_code('Approved')
    @overtime_flows = current_user.overtime_flows.joins(:overtime).where('overtimes.state_id' => approved_state)
    @overtime_flows = @overtime_flows.joins(:overtime).where('overtimes.created_at' => @start_time..@end_time).order('updated_at DESC')
  end
  
  def export
    @quick_date_ranges = params['quickDateRanges'] || '7'
    @date_from = params['date_from']
    @date_to = params['date_to']
    @start_time, @end_time, @date_filter = self.get_date_filter(@quick_date_ranges)
    
    approved_state = OvertimeState.find_by_code('Approved')
    @overtime_flows = current_user.overtime_flows.joins(:overtime).where('overtimes.state_id' => approved_state)
    @overtime_flows = @overtime_flows.joins(:overtime).where('overtimes.created_at' => @start_time..@end_time).order('updated_at DESC')
    
    respond_to do |format|
      format.csv {
        send_data(csv_content_for(@overtime_flows),  
        :type => "text/csv;charset=utf-8; header=present",  
        :filename => "Report_Overtimes_#{Time.now.strftime("%Y%m%d")}.csv") 
      }
    end
  end
  
  def csv_content_for(overtime_flows)
    csv_string = CSV.generate do |csv|
      csv << ["基本信息"]
      csv << ["姓名", current_user.chinese_name]
      csv << ["部门"]
      csv << ["入职日期"]
      csv << ["已休年假天数"]
      csv << ["年假剩余天数"]
      csv << ['']
      csv << ["加班信息"]
      csv << ['', "标题", "开始时间", "结束时间", "加班时间(小时)"]
      
      overtime_flows.each_with_index do |flow, index|
        csv << [index+1, flow.overtime.subject, flow.overtime.start_time, flow.overtime.end_time, flow.overtime.total_time]
      end
    end
    return csv_string
  end
  
  def get_date_filter(quick_date_ranges)
      start_time = ''
      end_time = ''
      date_filter = ''
      # date_filter = '1'
      case quick_date_ranges        
      when '0'  # custom
        start_time = DateTime.strptime(params['date_from'], '%Y-%m-%d')
        end_time = DateTime.strptime(params['date_to'], '%Y-%m-%d')
        end_time = Time.new(end_time.year, end_time.month, end_time.day, 23, 59, 59)
        date_filter = '时间范围：' + params['date_from'] + ' - ' + params['date_to']
      when '1'  # today
        now = Time.now
        start_time = Time.new(now.year, now.month, now.day, 0, 0, 0)
        end_time = Time.new(now.year, now.month, now.day, 23, 59, 59)
        date_filter = '时间范围：' + now.strftime('%Y-%m-%d')
      when '2'  # yestoday
        now = Time.now
        yestoday = now - 1.day
        start_time = Time.new(yestoday.year, yestoday.month, yestoday.day, 0, 0, 0)
        end_time = Time.new(yestoday.year, yestoday.month, yestoday.day, 23, 59, 59)
        date_filter = '时间范围：' + yestoday.strftime('%Y-%m-%d')
      when '3' # this week
        now = Time.now
        monday = now - (now.wday-1).day
        sunday = monday + 6.day
        start_time = Time.new(monday.year, monday.month, monday.day, 0, 0, 0)
        end_time = Time.new(sunday.year, sunday.month, sunday.day, 23, 59, 59)
        date_filter = '时间范围：' + start_time.strftime('%Y-%m-%d') + ' - ' + end_time.strftime('%Y-%m-%d')
      when '4'  # last week
        now = Time.now
        last_monday = now - (now.wday-1+7).day
        last_sunday = last_monday + 6.day
        start_time = Time.new(last_monday.year, last_monday.month, last_monday.day, 0, 0, 0)
        end_time = Time.new(last_sunday.year, last_sunday.month, last_sunday.day, 23, 59, 59)
        date_filter = '时间范围：' + start_time.strftime('%Y-%m-%d') + ' - ' + end_time.strftime('%Y-%m-%d')
      when '5'  # this month
        now = Time.now
        first_day_of_month = Time.new(now.year, now.month, 1, 0, 0, 0)
        last_day_of_month = Time.new(now.year, now.month+1, 1, 0, 0, 0) - 1.day
        start_time = Time.new(first_day_of_month.year, first_day_of_month.month, first_day_of_month.day, 0, 0, 0)
        end_time = Time.new(last_day_of_month.year, last_day_of_month.month, last_day_of_month.day, 23, 59, 59)
        date_filter = first_day_of_month.strftime('时间范围：%Y年%m月')
      when '6'  # last month
        now = Time.now
        first_day_of_month = Time.new(now.year, now.month-1)
        last_day_of_month = Time.new(now.year, now.month, 1, 0, 0, 0) - 1.day
        start_time = Time.new(first_day_of_month.year, first_day_of_month.month, first_day_of_month.day, 0, 0, 0)
        end_time = Time.new(last_day_of_month.year, last_day_of_month.month, last_day_of_month.day, 23, 59, 59)
        date_filter = first_day_of_month.strftime('时间范围：%Y年%m月')
      when '7'  # this year
        now = Time.now
        start_time = Time.new(now.year, 1, 1, 0, 0, 0)
        end_time = Time.new(now.year, 12, 31, 23, 59, 59)
        # date_filter = u'时间范围：' + u'%s年' % (now.year)
        date_filter = now.strftime('时间范围：%Y年')
      when '8'  # last year
        now = Time.now
        start_time = Time.new(now.year-1, 1, 1, 0, 0, 0)
        end_time = Time.new(now.year-1, 12, 31, 23, 59, 59)
        date_filter = '时间范围：%d年' % (now.year-1)
      end
        
      return [start_time, end_time, date_filter]
  end
end
