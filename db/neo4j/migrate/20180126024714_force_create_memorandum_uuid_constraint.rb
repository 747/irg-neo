class ForceCreateMemorandumUuidConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :Memorandum, :uuid, force: true
  end

  def down
    drop_constraint :Memorandum, :uuid
  end
end
