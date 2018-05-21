require './environment'
require './helpers'
require 'sinatra'
require 'active_support'
require 'active_support/core_ext'
require 'sinatra/reloader' #if development?
require 'sinatra/multi_route'
require 'sinatra/url_for'
require 'json'

class IRGT < Sinatra::Base
  register Sinatra::MultiRoute
  set :bind, '0.0.0.0'
  # set :port, 80 if Sinatra::Base.environment == 'production'
  helpers RadicalUtils
  helpers BuilderUtils
  helpers Sinatra::UrlForHelper

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
            @editing = target.instance_variable_get(:@attributes).slice('uuid', 'short_name', 'title').symbolize_keys
          elsif params[:docid]
            @note << [:invalid_doc, params[:docid]]
          end

          @nextsn, @prevsn = list[idx == list.length-1 ? 0 : idx+1][:serial], list[idx-1][:serial]
          @charsn, @charcode = list[idx].values_at(:serial, :code)
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

      order_index = @motions.map { |m| m[0][:document] } if @motions
      @sorter = order_index.map { |i| i.date }
      # insert the dummy entry for editing mode
      if target
        if (found = order_index.index(target))
          @sorter.insert found, true
        else
          found = @sorter.index { |s| s <= target.date } || -1 # find the latest entry before target
          @sorter.insert found, false
        end
        
        @motions.insert found, [{document: target}, true]
      end

    else
      @note << [:invalid_set, params[:set]]
    end

    # TODO: put on some Decorator whenever convenient...
    slim :carousel
  end

  get '/docs/:docid' do
    # とりあえず
    @note = []
    doc = Memorandum.find_by short_name: params[:docid]
    if doc
      @doc = doc
    else
      @note << [:invalid_doc, params[:docid]]
    end

    slim :gallery
  end

  post '/edit-motion/:docid/:charid' do
    begin
      fields = JSON.parse request.body.read
      the_doc = Memorandum.find_by! short_name: params[:docid]
      the_char = Character.find_by! code: params[:charid]
      cands = the_doc.motions(:m).char.match_to(the_char).pluck(:m)
      
      target =
        if cands.blank?
          CharMotion.new document: the_doc, char: the_char
        elsif cands.size == 1
          cands.first
        else
          raise
        end
      
      fields['props'].each { |k, v|
        case k
        when 'unified'
          target.unifiers = v.split(',').map { |vv|
            u = vv.strip
            case u
            when /^\d+$/
              # TODO
              # Series.all.where(short_name: fields['ref']['set']).chars.where(migrated: ).rel_where(serial: u.to_i)
            when /^U-(\h{8})$/
              cp = 4.times.reduce($1) { |m, _| m = m[1..-1] if m[0] == '0' }
              Character.find_by! code: "U+#{cp}"
            else
              Character.find_by! code: u
            end
          }
        else
          target[k.intern] = v unless v.blank?
        end
      }
      target.save!
      status 200
    rescue
      status 502
      body JSON.dump(doc: the_doc, char: the_char, cands: cands, fields: fields, t: target)
    end
  end
end
