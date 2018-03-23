require 'neo4j'

# References
# https://github.com/neo4jrb/neo4j/issues/561
#

#
# Nodes
#

class Memorandum
  include Neo4j::ActiveNode
  include Neo4j::Timestamps
  property :title, type: String
  property :short_name, type: String#, constraint: :unique # non-obligatory prop
  property :assigned_on, type: DateTime

  validates :title, :assigned_on, presence: true

  has_many :out, :motions, rel_class: :Contains, model_class: :CharMotion
  has_many :in, :authors, rel_class: :Writes
end

class Document < Memorandum
  include Neo4j::ActiveNode
  include Neo4j::Timestamps
  property :doc_id, type: String#, constraint: :unique
  property :published_on, type: DateTime

  validates :doc_id, presence: true

  has_many :out, :re, rel_class: :RespondsTo
  has_many :in, :responses, rel_class: :RespondsTo
  has_many :out, :files, rel_class: :HasFile
end

class Series
  include Neo4j::ActiveNode
  include Neo4j::Timestamps
  property :name, type: String
  property :short_name, type: String#, constraint: :unique

  validates :name, :short_name, presence: true

  has_many :in, :chars, rel_class: :Constitutes
end

class Source < Series
  property :prefix, type: String#, constraint: :unique

  validates :prefix, presence: true
end

class Character
  include Neo4j::ActiveNode
  include Neo4j::Timestamps
  property :code, type: String
  property :utf8, type: String

  validates :code, presence: true

  has_many :in, :motions, rel_class: :On
  has_many :out, :successor_claims, rel_class: :MigratesFrom
  has_many :out, :series, rel_class: :Constitutes
  has_many :in, :unifiee_claims, rel_class: :UnifiedBy
  has_many :both, :migrated, type: false, model_class: :Migration
end

class CharMotion
  include Neo4j::ActiveNode
  include Neo4j::Timestamps
  include Neo4j::UndeclaredProperties
  property :rad, type: Integer
  property :sc, type: Integer
  property :fs, type: Integer
  property :ts, type: Integer
  property :ids, type: String
  property :similar, type: String
  property :total, type: Integer
  property :comment, type: String
  enum status: [:live, :postponed, :withdrawn]

  # validates :rad, :sc, :fs, :ts, :ids, :total, presence: true

  has_many :out, :re, rel_class: :Answers
  has_many :in, :answers, rel_class: :Answers
  has_many :out, :evidences, rel_class: :HasEvidence, dependent: :delete_orphans
  has_many :out, :unifiers, rel_class: :UnifiedBy
  has_many :in, :precedessors, rel_class: :MigratesFrom
  has_one :out, :char, rel_class: :On, model_class: :Character
  has_one :out, :glyph, rel_class: :HasGlyph, model_class: :Glyph, dependent: :delete_orphans
  has_one :in, :document, rel_class: :Contains, model_class: :Memorandum
end

class DataFile
  include Neo4j::ActiveNode
  include Neo4j::Timestamps
  property :name, type: String
  property :filetype, type: String
  property :path, type: String

  validates :name, :filetype, presence: true
end

class Image < DataFile
end

class Glyph < Image
end

class Evidence < Image
end

class Agent
  include Neo4j::ActiveNode
  include Neo4j::Timestamps

  property :name, type: String

  validates :name, presence: true

  has_many :out, :documents, rel_class: :Writes
end

class Person < Agent
end

class Organization < Agent
end

class Meeting
  include Neo4j::ActiveNode
  include Neo4j::Timestamps
end

class Redirection
  include Neo4j::ActiveNode
  include Neo4j::Timestamps

  has_one :out, :to, rel_class: :RedirectsTo
  has_one :out, :from, rel_class: :RedirectsFrom
  has_one :in, :document, rel_class: :Contains
end

#
# Relations
#

class Contains
  include Neo4j::ActiveRel
  include Neo4j::Timestamps
  creates_unique
  from_class :Memorandum
  to_class :any
end

class RespondsTo
  include Neo4j::ActiveRel
  include Neo4j::Timestamps
  creates_unique
  from_class :Document
  to_class :Document
end

class Answers
  include Neo4j::ActiveRel
  include Neo4j::Timestamps
  creates_unique
  from_class :CharMotion
  to_class :CharMotion

  enum effect: [:agree, :disagree]
end

class UnifiedBy
  include Neo4j::ActiveRel
  include Neo4j::Timestamps
  creates_unique
  from_class :CharMotion
  to_class :Character

  enum operation: [:unknown, :substitute, :extend, :ivd], _default: :unknown
end

class HasGlyph
  include Neo4j::ActiveRel
  include Neo4j::Timestamps
  creates_unique
  from_class :CharMotion
  to_class :Glyph
end

class HasEvidence
  include Neo4j::ActiveRel
  include Neo4j::Timestamps
  include Neo4j::UndeclaredProperties
  from_class :CharMotion
  to_class :Evidence
end

class HasFile
  include Neo4j::ActiveRel
  include Neo4j::Timestamps
  creates_unique
  from_class :Document
  to_class :DataFile
end

class On
  include Neo4j::ActiveRel
  include Neo4j::Timestamps
  creates_unique
  from_class :CharMotion
  to_class :Character
end

class Constitutes
  include Neo4j::ActiveRel
  include Neo4j::Timestamps
  creates_unique
  from_class :Character
  to_class :Series

  property :serial, type: Integer
end

class MigratesFrom
  include Neo4j::ActiveRel
  include Neo4j::Timestamps
  creates_unique
  from_class :Character
  to_class :CharMotion
end

class RedirectsFrom
  include Neo4j::ActiveRel
  include Neo4j::Timestamps
  creates_unique
  from_class :Redirection
  to_class :Character
end

class RedirectsTo
  include Neo4j::ActiveRel
  include Neo4j::Timestamps
  creates_unique
  from_class :Redirection
  to_class :Character
end

class Writes
  include Neo4j::ActiveRel
  include Neo4j::Timestamps
  creates_unique
  from_class :Agent
  to_class :Memorandum
end
