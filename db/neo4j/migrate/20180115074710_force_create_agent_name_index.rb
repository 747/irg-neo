class ForceCreateAgentNameIndex < Neo4j::Migrations::Base
  def up
    add_index :Agent, :name, force: true
  end

  def down
    drop_index :Agent, :name
  end
end
