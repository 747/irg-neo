require 'bundler'
Bundler.setup
require 'neo4j'
require 'neo4j-core'
require 'socket' # The Bolt adapter forgot to require this library when using TCPSocket
require 'neo4j/core/cypher_session/adaptors/http'
require 'neo4j/core/cypher_session/adaptors/bolt'
require './login'

# Reference: https://github.com/neo4jrb/neo4j/issues/1344
options = {wrap_level: :proc} # Required to be able to use `Object.property` and `Object.relatedObject

neo4j_adaptor = Neo4j::Core::CypherSession::Adaptors::HTTP.new("http://#{$USR}:#{$PWD}@localhost:7474", options)
# Bolt buggy cf. https://github.com/neo4jrb/neo4j/issues/1317
# neo4j_adaptor = Neo4j::Core::CypherSession::Adaptors::Bolt.new('bolt://irgtracker:nobody_expects_the_spanish_inquisition@localhost:7687', options)
Neo4j::ActiveBase.on_establish_session { Neo4j::Core::CypherSession.new(neo4j_adaptor) }

# Dir["models/concerns/*.rb"].each do |concern|
#   load concern
# end

Dir["models/**/*.rb"].each do |model|
  load model
end

$TIMESTAMP = "%Y%m%d%H%M%S%L%Z"

# https://gist.github.com/andreasronge/4516914
class TransactionalExec
  attr_accessor :commit_every, :block

  def initialize(commit_every, max_lines = nil, verbose = true, &block)
    @commit_every = commit_every
    @block = block
    @max_lines = max_lines
    @verbose = verbose
  end

  def execute(enumerable)
    time_of_all = Time.now
    tx = Neo4j::Transaction.new(Neo4j::ActiveBase.current_session)
    time_in_ruby = Time.now
    index = 0
    enumerable.each_with_index do |item, item_idx|

      @block.call(item, item_idx)
      index += 1
      if (index % @commit_every == 0)
        time_spent_in_ruby_code = Time.now - time_in_ruby
        time_spent_in_write_to_file = Time.now
        tx.close # commits if not failed
        tx = Neo4j::Transaction.new(Neo4j::ActiveBase.current_session)
        puts "  Written #{index} items. time_spend_in_ruby_code: #{time_spent_in_ruby_code}, time_spent_in_write_to_file #{Time.now - time_spent_in_write_to_file}" if @verbose
        time_in_ruby = Time.now
      end
      break if @max_lines && index > @max_lines
    end

    tx.close # commits if not failed
    puts "Total, written #{index} items in #{Time.now - time_of_all} sec." if @verbose
  end
end
