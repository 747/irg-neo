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

  get '/site-css/*.css' do
    sass :"stylesheets/#{params[:splat].join('/')}"
  end

  get '/browse/:set/:serial/?:ver?', '/source/:source/:charid' do
    mode = params[:set].present? ? 1 : params[:source].present? ? 2 : 0
    @note = []
    @set = [nil, params[:set], params[:source]][mode]

    if @set && (the_set = Series.find_by(short_name: @set))
      case mode
      when 1
        list = the_set.chars(:c)&.where_not('(c)-[:REDIRECTS_FROM]-()')&.each_with_rel&.map { |c, r| [r.serial, c.code] }.sort_by {|s| s[0] }
        if list.present?
          if params[:serial] =~ /\A\d+\z/
            num = params[:serial].to_i
          else
            num = 0
            @note << [:invalid_char, params[:serial]]
          end

          unless idx = list.index { |e| e[0] == num }
            idx = 0
            @note << [:invalid_char, params[:serial]]
          end

          @nextsn, @prevsn = list[idx == list.length-1 ? 0 : idx+1][0], list[idx-1][0]
          @charsn, @charcode = list[idx]
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

  get '/edit/:doc/:set/:serial' do
  end
end
