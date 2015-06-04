class AlterColumnCheckLinksChecedUrl < ActiveRecord::Migration
  def change
    	rename_column :check_links, :checked_url, :checked_url
  
  end
end
