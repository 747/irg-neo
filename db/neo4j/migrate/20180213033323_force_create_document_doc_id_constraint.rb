class ForceCreateDocumentDocIdConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :Document, :doc_id, force: true
  end

  def down
    drop_constraint :Document, :doc_id
  end
end
