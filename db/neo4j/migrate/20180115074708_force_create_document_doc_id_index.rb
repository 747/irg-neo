class ForceCreateDocumentDocIdIndex < Neo4j::Migrations::Base
  def up
    add_index :Document, :doc_id, force: true
  end

  def down
    drop_index :Document, :doc_id
  end
end
