class ForceCreateSourcePrefixConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :Source, :prefix, force: true
  end

  def down
    drop_constraint :Source, :prefix
  end
end
