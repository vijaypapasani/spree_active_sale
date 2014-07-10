class AddDesignerPositionToSpreeActivesaleEvent < ActiveRecord::Migration
  def change
  	add_column :spree_sale_events, :designer_position, :integer
  end
end
