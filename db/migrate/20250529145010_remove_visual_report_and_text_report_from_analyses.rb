class RemoveVisualReportAndTextReportFromAnalyses < ActiveRecord::Migration[7.1]
  def change
    remove_column :analyses, :visual_report, :jsonb
    remove_column :analyses, :text_report, :jsonb
  end
end
