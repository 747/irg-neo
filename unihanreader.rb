require './environment'
require 'bigdecimal'
require 'bigdecimal/util'
require 'active_support'
require 'active_support/core_ext'
require 'yaml'
require 'pathname'

abort("Needs 2 arguments: DOCDEFPATH DIRPATH") if 2.times.reduce(false) { |m, a| m ||= ARGV[a].blank? }

docdef = YAML.load_file(ARGV[0]).deep_symbolize_keys[:document]
dir = Pathname ARGV[1]

set = Series.find_or_create_by!(name: 'Unicode') { |s| s.short_name = 'UC' }
doc = Document.find_or_create_by!(docdef.slice(:doc_id)) { |d|
  docdef.slice(:title, :assigned_on, :published_on).each { |k, v| d[k] = v }
}
# existing = Character.all(:c).branch { series.where(name: set[:name]) }.motions(:m).branch { document.where(short_name: doc[:short_name]) }.pluck(:c, :m)
chars = {}

# とりあえずこれだけ
print "IRGSources..."
open(dir + 'Unihan_IRGSources.txt', 'r:UTF-8') do |dat|
  dat.each.with_index { |line, lnum|
    case line.strip
    when /^#/
      next
    when /^(?<code>\S+)\t(?<prop>\S+)\t(?<val>\S+)/
      print "\rIRGSources -- #{lnum}"
      m = Regexp.last_match
      enc = m[:code].sub(/U\+/, '').hex.chr('UTF-8')
      char = (chars[m[:code]] ||= {cp: enc})
      char[m[:prop].intern] = m[:val]
    end
  }
end
print "\n"

print "updating DB..."
chunks = chars.keys.each_slice(200).to_a
count = chunks.size
chunks.each.with_index(1) do |group, index|
  gr = group.compact
  Neo4j::ActiveBase.run_transaction {
    print "\rupdating DB -- #{gr[0]} - #{gr[-1]} (#{index}/#{count})          "
    gr.each do |id|
      props = chars[id]
      ch = Character.find_or_create_by!(code: id) { |c| c[:utf8] = props[:cp] }
      mo = ch.motions(:m).document.match_to(doc).pluck(:m).first || CharMotion.create
      props.except(:cp).each { |k, v| mo[k] = v }
      mo.char = ch
      mo.document = doc
      mo.save

      ch.series.create set
      ch.save
    end
  }
end
print "\n"