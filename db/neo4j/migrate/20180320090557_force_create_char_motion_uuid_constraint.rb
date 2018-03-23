class ForceCreateCharMotionUuidConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :CharMotion, :uuid, force: true
  end

  def down
    drop_constraint :CharMotion, :uuid
  end
end
