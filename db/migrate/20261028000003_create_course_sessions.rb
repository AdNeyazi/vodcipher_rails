class CreateCourseSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :course_sessions do |t|
      t.references :course, null: false, foreign_key: true
      t.string  :title, null: false
      t.integer :position, null: false, default: 0
      t.string  :vdocipher_video_id, null: false   # the ONLY thing we store about the video
      t.integer :duration                          # seconds, filled from VdoCipher
      t.string  :status, null: false, default: "processing" # processing / ready / failed
      t.boolean :preview, null: false, default: false       # watchable without enrolling
      t.timestamps
    end
    add_index :course_sessions, %i[course_id position]
  end
end
