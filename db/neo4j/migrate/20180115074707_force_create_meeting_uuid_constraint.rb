class ForceCreateMeetingUuidConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :Meeting, :uuid, force: true
  end

  def down
    drop_constraint :Meeting, :uuid
  end
end
