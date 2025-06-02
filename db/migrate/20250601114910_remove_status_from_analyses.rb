class RemoveStatusFromAnalyses < ActiveRecord::Migration[7.1]
  def change
    remove_column :analyses, :status, :string
  end
end
