class CreateSessionProgresses < ActiveRecord::Migration[7.1]
  def change
    create_table :session_progresses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course_session, null: false, foreign_key: true
      t.integer :watched_seconds, null: false, default: 0
      t.boolean :completed, null: false, default: false
      t.timestamps
    end
    add_index :session_progresses, %i[user_id course_session_id], unique: true
  end
end
