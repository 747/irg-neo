class ForceCreateDataFileUuidConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :DataFile, :uuid, force: true
  end

  def down
    drop_constraint :DataFile, :uuid
  end
end
