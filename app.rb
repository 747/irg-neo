require './environment'
require './helpers'
require 'sinatra'
require 'active_support'
require 'active_support/core_ext'
require 'sinatra/reloader' #if development?
require 'sinatra/multi_route'

class IRGT < Sinatra::Base
  register Sinatra::MultiRoute
  set :bind, '0.0.0.0'
  # set :port, 80 if Sinatra::Base.environment == 'production'
  helpers RadicalUtils
  helpers BuilderUtils

  get '/' do
    'TODO!'
  end

  get '/images/*' do
    redirect 'http://placehold.jp/13/a4a5a6/ededed/50x50.png?text=Image%0AComing%0ASoon'
  end

  get '/site-js/*.js' do
    coffee :"javascripts/#{params[:splat].join('/')}"
  end

  get '/site-css/*.css' do
    sass :"stylesheets/#{params[:splat].join('/')}"
  end

  get '/browse/:set/:serial/?:ver?', '/edit/:docid/:set/:serial', '/source/:source/:charid' do
    mode = params[:set].present? ? 1 : params[:source].present? ? 2 : 0
    @note = []
    @set = [nil, params[:set], params[:source]][mode]

    if @set && (the_set = Series.find_by(short_name: @set))
      case mode
      when 1
        list = query_list(the_set)
        if list.present?
          if params[:serial] =~ /\A\d+\z/
            num = params[:serial].to_i
          else
            num = 0
            @note << [:invalid_char, params[:serial]]
          end

          unless idx = list.index { |e| e[:serial] == num }
            idx = 0
            @note << [:invalid_char, params[:serial]]
          end

          target = params[:docid].present? ? Memorandum.find_by(short_name: params[:docid]) : nil
          if target
            @editing = target.attributes.slice(:uuid, :short_name, :title)
          elsif params[:docid]
            @note << [:invalid_doc, params[:docid]]
          end

          @nextsn, @prevsn = list[idx == list.length-1 ? 0 : idx+1][:serial], list[idx-1][:serial]
          @charsn, @charcode = list[idx].fetch_values(:serial, :code)
          @motions = query_browse(the_set, @charsn)
        else
          @note << [:empty_set, @set]
        end
      when 2
        char = the_set.chars.where(code: params[:charid]).first
        if char.present?
          @set_name = the_set.name
          @charcode = char.code
          @motions = query_browse(the_set, @charcode, false)
        else
          @note << [:invalid_code, @charcode]
        end
      end
    else
      @note << [:invalid_set, params[:set]]
    end
    slim :carousel
  end
end
