class ForceCreateCharMotionStatusIndex < Neo4j::Migrations::Base
  def up
    add_index :CharMotion, :status, force: true
  end

  def down
    drop_index :CharMotion, :status
  end
end
