require './environment'
require 'roo'
require 'roo-xls'
require 'bigdecimal'
require 'bigdecimal/util'
require 'active_support'
require 'active_support/core_ext'
require 'hashdiff'
require 'yaml'
require 'pathname'
require 'set'

abort("Needs 2 arguments: DOCDEFPATH BOOKPATH") if 2.times.reduce(false) { |m, a| m ||= ARGV[a].blank? }
STDOUT.sync = true

docdef = YAML.load_file(ARGV[0]).deep_symbolize_keys[:document]
config = YAML.load_file( Pathname(ARGV[0]).dirname + "#{docdef[:format]}.yml" ).deep_symbolize_keys
c = config[:constants]
spr = Roo::Spreadsheet.open ARGV[1]
testing = ARGV[2].present?

s = c[:series]
set_attr = -> o, h { h.each_pair { |k, v| o[k] = v } }
set = Series.find_or_create_by!(s.slice(:name)) do |sr|
  set_attr[sr, s.slice(:short_name)]
end
doc = Document.find_or_create_by!(docdef.slice(:doc_id)) do |d|
  set_attr[d, docdef.slice(:title, :assigned_on, :published_on)]
end
uc_latest = Series.find_by!(short_name: 'UC').chars.motions.document.order(published_on: :desc).first
prefixes = c[:prefixes]
usources = %w[G H J KP K M T U V]

# parse spreadsheets
warnings = []
chars = []
known_glyphs = Set.new
known_evids = Set.new
fields = config[:fields].map { |f| f[0] = f[0][1..-1].intern if /^:/ =~ f[0]; f } # Psych cannot handle symbols correctly cf. https://github.com/ruby/psych/issues/12
warnr = -> n, m { warnings << ("Row ##{'% 4d' % n}: " << m) }
proofread = -> str, match, row, col, callback {
  match.select { |k, v|
    k.start_with?('warn-') && v && v.empty? ||
    k.start_with?('unwarn-') && v && !v.empty?
  }.each { |k, v|
    callback[row, "Format oversight! <#{k}> in '#{str}' (#{col.is_a?(Integer) ? "col #{col}" : col})"]
  }
}
print "parsing..."
spr.sheets.size.times do |num| # How to officially do `each_with_pagename.with_index`?
  sheet = spr.sheet(num)
  next if sheet.last_row.to_i < 2

  live = num == (docdef[:live_sheet] || 0)
  header = []
  sheet.each.with_index(1) { |ch, ri|
    if ri == 1
      header = ch.map(&:strip); next
    end

    print "\rparsing -- #{num}#{'(live)' if live}: #{ri}" << (' ' * 10)
    char = {live: live}
    serial = nil
    fields.each_with_index do |f, i|
      next if f.blank?
      name, pre, pexp, sexp, ref = f[0..4]
      if name == :number
        serial = ch[i].to_i
      elsif ch[i]
        parent = pre ? (char[pre] ||= {}) : char
        entries = sexp ? ch[i].split(sexp) : [ch[i]]
        values = pexp ? entries.map { |e|
          m = e.match(pexp).named_captures
          proofread[ch[i], m, ri, i, warnr]
          m['name'] ||= pre ? c[name][pre.intern] : c[name]
          m.delete_if { |k, v| k =~ /^(?:un)?warn-/ }.symbolize_keys
        } : (entries.size > 1 ? entries : entries.first) # revert to string if possible
        parent[ name || header[i].intern ] = values
        parent[ref.delete(':').intern] ||= values if ref # insert this column's data only if the referenced key is uninput or blank
      end

      case name
      when :glyph, :evidence
        container = name == :glyph ? known_glyphs : known_evids
        case values
        when String
          container << values
        when Array
          values.each { |v| container << ( v.is_a?(String) ? v : v[:name] ) }
        end
      end
    end
    serial ? chars[serial] = char : warnr[ri, "No valid serial number!"]
  }
  print "\n"
end

# check record errors
warnh = -> n, m { warnings << ("S/N #{'%05d' % n}: " << m) }
print "processing disc. records..."
chars.each.with_index do |ch, chi|
  unless ch
    warnh[chi, 'Missing entry!'] if chi > 0
    next
  end

  print "\rprocessing disc. records -- ##{chi}"
  unless ch[:live]
    delim = /
      (?<=
        \d|
        IRGN2155\sUK\sReview
      )
      \.
      (?=\s+|\Z)
    /x
    target = /
      (?<withdrawn>Withdrawn?)|
      (?<postponed>Postponed|Pe(?<unwarn-typo-3-2>i?)n(?<unwarn-typo-3-1>g?)ding)|
      (?<not>Not\g<s>*(?:\g<unified>\g<warn-typo-1-2>\g<to>|\g<to>))| # pre-feed negative match to bleed positive
        (?:
          (?<unified>
            Un(?<warn-typo-1-1>i?)f(?:ied|y)(?<s>\s|(?<unwarn-corruption-1>[\p{Z}\p{C}]))
            (?:by|to|with)
          )
          (?<warn-typo-1-2>\g<s>*)
        )?
        (?:
          (?<to>
            (?<to-sn>0\d{4})|
            (?<to-un>(?:U\+)?(?<unwarn-typo-1-3>\s?)[[:xdigit:]]{4,5})
          )
          (?![a-zA-Z]) # prevent from matching "accepted"
          \g<s>*
        )
        (?<info>\p{Ideographic}+|\((?!\g<ivd>)[^)]+?\))?
        (?:.*(?<ivd>ivd|ivs))?|
      \g<ivd>
        .*?\g<s>\g<to>\g<s>*
        \g<info>?
    /xi
    matched_comments = ch[:comment].split(delim).map(&:strip).map { |m|
      ma = m.to_enum(:scan, target).map { $~ }.reject { |md| md['not'].present? }.first
      ma ? ma.named_captures.compact : m
    }
    remarks, failed_comments = matched_comments.partition { |m| m.is_a? Hash }
    failed_comments.each { |f| warnh[chi, "Please check the effectless comment '#{f}'"] }
    warnh[chi, "No valid rejection comment! '#{ch[:comment]}'"] if remarks.blank?

    case remarks.first&.keys&.select { |k| ['unified', 'to', 'ivd', 'postponed', 'withdrawn'].include? k }&.first
    when 'unified', 'to', 'ivd'
      remark = remarks.first
      proofread[ch[:comment], remark, chi, :comment, warnh]
      r2u, r2s, rinfo, rivd = remark['to-un'], remark['to-sn'], remark['info']&.delete('()'), remark['ivd']
      if r2u
        uc = r2u.delete('U+').hex.chr('UTF-8')
        warnh[chi, "Please check the codepoint sanity of #{r2u}/#{uc} vs #{ch[:ids]}"]
        if (udata = CharMotion.all(:m).branch { document.match_to(uc_latest) }.branch { char.where(utf8: uc) }.pluck(:m).first) # CAUTION: `branch` fails to shadow outer variable
          if rinfo
            is_source = usources.map { |s| udata[:"kIRG_#{s}Source"] }.include? rinfo
            is_uchar = udata.char.utf8 == rinfo
            warnh[chi, "Unmatched additional info! #{r2u} <-> #{rinfo}"] unless is_source || is_uchar
          end
          ch[:unified] = {name: uc}
        else
          warnh[chi, "Nonexistent character reference to #{r2u}!"]
        end
      elsif r2s
        sn = r2s.to_i
        target = chars[sn]
        if target.present?
          warnh[chi, "Unmatched additional info! #{r2s} <-> #{rinfo}"] if rinfo && ! prefixes.map { |s| target[s]&.[](:code) }.include?(rinfo)
          ch[:unified] = {name: sn}
        else
          warnh[chi, "Nonexistent S/N reference to #{r2s}!"]
        end
      else
        warnh[chi, "Invalid character reference to #{r2s}!"]
      end
      ch[:unified][:operation] = :ivd if rivd && ch[:unified]
    when 'withdrawn'
      ch[:withdrawn] = true
    when 'postponed'
      ch[:postponed] = true
    end
  end
end
print "\n"

# check ref. consistency and offset property values
trash_bin = {}
group = -> n, prefix {
  prim, aux = [prefix].flatten
  (g = chars[n][prim]) && aux ? g.merge(chars[n][aux]) : g
}
chain = -> n, a=[] { (d = chars[n][:unified]&.[](:name)).is_a?(Integer) ? chain[d, a << d] : a }
print "checking unification..."
chars.each.with_index do |ch, chi|
  next unless ch
  trace = chain[chi]

  print "\rchecking unification -- ##{chi}"#; warnh[chi, trace.map{|t|'%05d' % t}.join(' -> ')] if trace.present?
  trace.each { |t|
    prefixes.each do |pf|
      next unless (my_attrs = group[chi, pf])
      
      ref_attrs = group[t, pf]
      if ref_attrs
        same_id = my_attrs[:code] == ref_attrs[:code]
        unless my_attrs == ref_attrs
          warnh[chi, "Unmatched derived property value => #{'%05d' % t}" << HashDiff.diff(my_attrs, ref_attrs).map { |d| format "\n  %s %s: %s", *(d[3] ? d[0..1] << "#{d[2]} -> #{d[3]}" : d) }.join]

          # update current character's source-dependent properties according to final unifier's
          # i.e. add or change, but doesn't delete
          # (need to update source-independent ones too?)
          ch[pf.is_a?(Array) ? pf[0] : pf].merge(ref_attrs) if chars[t][:live] && same_id
        end

        # store matched property sets into temporary to-be-delete list
        # don't delete from unifier immediately lest disrupt many-to-one relationship
        trash_bin[t] = (trash_bin[t] || []) | [pf].flatten if same_id
      end
    end
  }
end
trash_bin.each do |t, list|
  list.each { |pre| chars[t].delete pre }
end
print "\n"

# resolve ref. and convert for DB
print "resolving unification..."
chars.each.with_index do |ch, chi|
  next unless ch
  print "\rresolving unification -- ##{chi}"
  exist = prefixes.map { |pf| [pf].flatten.reduce(true) { |m, e| m && ch[e] } }
  warnh[chi, "Has uncleared duplicate sources! #{exist.map.with_index { |e, i| e ? prefixes[i] : nil }.compact.join(', ')}"] if exist.compact.size > 1
  
  prefixes.each { |pf| [pf].flatten.each { |e|
    ch.update( ch[e] || {} )
    ch.delete e
  } }
end

open(Pathname('./output/check') + "#{Time.now.strftime($TIMESTAMP)}_#{s[:short_name]}_#{docdef[:doc_id]}.txt", "w:utf-8") do |w|
  warnings.each { |wa| w.puts wa }
end

# update!
if testing
  open(Pathname('./output/preview') + "#{Time.now.strftime($TIMESTAMP)}_#{docdef[:doc_id]}.yml", "w:utf-8") { |t|
    t.write YAML.dump(chars)
  }
else
  print "\n"

  print "retrieving chars..."
  characters = set.chars.map { |e| [e[:code], e] }.to_h
  puts "\r#{characters.size} existing chars found"

  print "retrieving glyphs..."
  glyphs = set.chars.motions.glyph.map { |e| [e[:name], e] }.to_h
  puts "\r#{glyphs.size} existing glyphs found"
  added_glyphs = known_glyphs - glyphs.keys.to_set
  TransactionalExec.new(1000) do |gl, i|
    added = Glyph.create(name: gl, filetype: File.extname(gl).delete('.'))
    glyphs[gl] = added
  end.execute(added_glyphs)
  puts "#{added_glyphs.size} new glyphs added"

  print "retrieving evidences..."
  evids = set.chars.motions.evidences.map { |e| [e[:name], e] }.to_h
  puts "\r#{evids.size} existing evidences found"
  added_evids = known_evids - evids.keys.to_set
  TransactionalExec.new(1000) do |ev, i|
    added = Evidence.create(name: ev, filetype: File.extname(ev).delete('.'))
    evids[ev] = added
  end.execute(added_evids)
  puts "#{added_evids.size} new evidences added"

  print "cleaning up DB..."
  # めんどくさいので一旦削除
  query = Neo4j::Core::Query.new.match("(s:Series {name: '#{set[:name]}'})--(c:Character)--(m:CharMotion)--(d:Document {doc_id: '#{doc[:doc_id]}'})").detach_delete(:m).return('count(m)')
  result = Neo4j::ActiveBase.current_session.query(query)
  existing = result.rows[0][0]
  puts "\rdeleted #{existing} motions on DB"

  print "updating DB..."
  rad2int = -> r { (r * 10).round }
  internal_refs = []
  unicode_refs = []

  TransactionalExec.new(1000) do |ch, chi|
    next if ch.blank?
    print "\rupdating DB -- ##{chi}"
    
    code = ch.delete(:code)
    char = characters[code] || Character.new(code: code)
    motion = CharMotion.new char: char, document: doc
    ch.each { |prop, val|
      case prop
      when :glyph
        gl = glyphs[val] || raise("Unknown glyph name #{val} in #{code}!")
        motion.glyph = gl
      when :evidence
        evs = val.is_a?(Array) ? val.map { |e| e.is_a?(Hash) ? e : {name: e.to_s} } : [{name: val}]
        evs.each { |v|
          ev = evids[v[:name]] || raise("Unknown evidence name #{v[:name]} in #{code}!")
          HasEvidence.create(motion, ev, v.except(:name))
        }
      when :live, :postponed, :withdrawn
        motion.status = prop if val
      when :unified
        unif = val.is_a?(Array) ? val : [val]
        unif.each { |u|
          case u[:name]
          when Integer
            internal_refs << [chi, u[:name], u.except(:name)]
          when String
            unicode_refs << [chi, u[:name], u.except(:name)]
          end
        }
        motion.status = :withdrawn
      when :rad
        motion[prop] = val.is_a?(Array) ? val.map(&rad2int) : rad2int[val]
      else
        motion[prop] = val.is_a?(Array) ? val.map(&:to_s) : val.to_s
      end
    }
    char.save
    motion.save
    Constitutes.create char, set, serial: chi
  end.execute(chars)
  # print "\n"

  puts "inserting unification:"
  print "  internals..."
  internal_refs.each.with_index(1) { |r, idx|
    print "\r  internals -- #{idx}/#{internal_refs.size}"
    nodes = r[0..1].map { |e| set.chars(:c).rel_where(serial: e).motions(:m).document.match_to(doc).pluck(:c, :m).first }
    if nodes.reduce(true, &:&)
      UnifiedBy.create! nodes[0][1], nodes[1][0], r[2]
    else
      raise "Invalid serial number #{r[0..1].join(' or ')} under #{set.short_name}"
    end
  }
  print "\n"
  print "  externals..."
  unicode_refs.each.with_index(1) { |r, idx|
    print "\r  externals -- #{idx}/#{unicode_refs.size}"
    if (origin = set.chars(:c).rel_where(serial: r[0]).motions(:m).document.match_to(doc).pluck(:m).first)
      UnifiedBy.create! origin, Character.find_by!(utf8: r[1]), r[2]
    else
      raise "Invalid serial number #{r[0]} under #{set.short_name}"
    end
  }
end
print "\n"