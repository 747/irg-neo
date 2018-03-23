class ForceCreateMemorandumShortNameConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :Memorandum, :short_name, force: true
  end

  def down
    drop_constraint :Memorandum, :short_name
  end
end
