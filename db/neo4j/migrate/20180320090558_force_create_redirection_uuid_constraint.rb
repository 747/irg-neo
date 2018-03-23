class ForceCreateRedirectionUuidConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :Redirection, :uuid, force: true
  end

  def down
    drop_constraint :Redirection, :uuid
  end
end
