class ForceCreateDocumentShortNameConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :Document, :short_name, force: true
  end

  def down
    drop_constraint :Document, :short_name
  end
end
