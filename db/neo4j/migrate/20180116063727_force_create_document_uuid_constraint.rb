class ForceCreateDocumentUuidConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :Document, :uuid, force: true
  end

  def down
    drop_constraint :Document, :uuid
  end
end
