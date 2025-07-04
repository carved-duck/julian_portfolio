class CreateBlogPosts < ActiveRecord::Migration[7.1]
  def change
    create_table :blog_posts do |t|
      t.string :title
      t.text :body
      t.datetime :published_at
      t.string :slug

      t.timestamps
    end
  end
end
