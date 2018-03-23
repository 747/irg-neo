require './environment'
require './helpers'
require 'sinatra'
require 'active_support'
require 'active_support/core_ext'
require 'sinatra/reloader' #if development?

class IRGT < Sinatra::Base
  set :bind, '0.0.0.0'
  # set :port, 80 if Sinatra::Base.environment == 'production'
  helpers RadicalUtils

  get '/' do
    'TODO!'
  end

  get '/site-css/*.css' do
    sass :"stylesheets/#{params[:splat].join('/')}"
  end

  get '/browse/:set/:serial/?:ver?' do
    return 'Not found!' if params[:set].empty?
    @note = []
    @set = params[:set]
    the_set = Series.find_by(short_name: params[:set])
    list = the_set&.chars(:c)&.where_not('(c)-[:REDIRECTS_FROM]-()')&.each_with_rel&.map { |c, r| [r.serial, c.code] }.sort_by {|s| s[0] }
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
      @motions = the_set.chars.rel_where(serial: @charsn).motions(:m).document.order(published_on: :desc).pluck(:m)
    else
      @note << [:empty_set, params[:set]]
    end
    slim :carousel
  end

  get '/edit/:doc/:set/:serial' do
  end
end
