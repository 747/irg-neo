class ForceCreateSourceNameIndex < Neo4j::Migrations::Base
  def up
    add_index :Source, :name, force: true
  end

  def down
    drop_index :Source, :name
  end
end
