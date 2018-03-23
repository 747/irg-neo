class ForceCreateSourceShortNameConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :Source, :short_name, force: true
  end

  def down
    drop_constraint :Source, :short_name
  end
end
