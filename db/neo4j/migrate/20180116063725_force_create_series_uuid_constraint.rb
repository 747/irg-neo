class ForceCreateSeriesUuidConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :Series, :uuid, force: true
  end

  def down
    drop_constraint :Series, :uuid
  end
end
