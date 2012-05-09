require 'csv'

class EventsController < ApplicationController
  def index
    @title = 'Events'
    @events = Event.all
  end
  
  def show
    @event = Event.find(params[:id])
    @title = @event.name
  end
  
  def new
    @title = 'Create New Event'
    @event = Event.new
  end

  def new_batch
    beginIndex = Integer(params[:begin])
    endIndex = Integer(params[:end])
    nameIndex = Integer(params[:name])
    @events = []

    CSV.parse(session[:import_file]) do |row|
      @events << Event.new(:name => row[nameIndex], :start_time => row[beginIndex], :end_time => row[endIndex])

    end
  end
  
  def create
    @event = Event.new(params[:event])
    if @event.save
      flash[:success] = "Event Created!"
      redirect_to @event
    else
      @title = "Create New Event"
      render 'new'
    end
  end

  def create_batch
    selections = params[:events]
    names = params[:names]
    start_times = params[:start_times]
    end_times = params[:end_times]
    event_candidates = CSV.parse(session[:import_file])
    selections.each do | index |
      i = Integer(index)
      @event = Event.new
      @event.name = names[i]
      @event.start_time = start_times[i]
      @event.end_time = end_times[i]
      @event.save
    end
    redirect_to :action => 'index'
  end

  def mappings
    @fields = params[:fields]
    @file = session[:import_file]
  end

  def upload
    if request.post? && params[:file].present?
      infile = params[:file].read
      session[:import_file] = infile
      n, errs = 0, []

      @fields  = infile.parse_csv   # from CSV
      if (!@fields.nil?)
        redirect_to :action => 'mappings', :fields => @fields
      end
    end
  end
end
