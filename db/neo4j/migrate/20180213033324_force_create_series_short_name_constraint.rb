class ForceCreateSeriesShortNameConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :Series, :short_name, force: true
  end

  def down
    drop_constraint :Series, :short_name
  end
end
