class ForceCreateCharacterUuidConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :Character, :uuid, force: true
  end

  def down
    drop_constraint :Character, :uuid
  end
end
