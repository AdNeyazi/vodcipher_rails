# Demo data. Safe to run more than once.
#
# To play real video, export your VdoCipher video ids BEFORE seeding:
#   export VDOCIPHER_DEMO_VIDEO_IDS=id1,id2,id3
# Otherwise sessions get placeholder ids; edit them in /admin.

admin = User.find_or_create_by!(email: "admin@example.com") do |u|
  u.name = "Admin"
  u.password = "password123"
  u.admin = true
end

student = User.find_or_create_by!(email: "student@example.com") do |u|
  u.name = "Student"
  u.password = "password123"
end

ids = ENV.fetch("VDOCIPHER_DEMO_VIDEO_IDS", "").split(",").map(&:strip).reject(&:blank?)

rails_course = Course.find_or_create_by!(title: "Ruby on Rails Basics") do |c|
  c.description = "Build your first Rails app, step by step. Every lesson is a DRM-protected VdoCipher video."
end

["Introduction", "Setting up Rails", "Models and Migrations", "Controllers and Views"].each_with_index do |title, i|
  rails_course.course_sessions.find_or_create_by!(position: i + 1) do |s|
    s.title = title
    s.vdocipher_video_id = ids[i] || "REPLACE_ME_#{i + 1}"
    s.status = ids[i] ? "ready" : "processing"
    s.preview = i.zero?
  end
end

advanced = Course.find_or_create_by!(title: "Advanced Rails Patterns") do |c|
  c.description = "Service objects, background jobs and performance. Not enrolled by default, so you can try the enroll flow."
end

["Service Objects", "Background Jobs"].each_with_index do |title, i|
  advanced.course_sessions.find_or_create_by!(position: i + 1) do |s|
    s.title = title
    s.vdocipher_video_id = ids[i + 4] || "REPLACE_ME_ADV_#{i + 1}"
    s.status = ids[i + 4] ? "ready" : "processing"
  end
end

Enrollment.find_or_create_by!(user: student, course: rails_course)

puts "Seeded: #{User.count} users, #{Course.count} courses, #{CourseSession.count} sessions."
puts "Login: admin@example.com / password123  |  student@example.com / password123"
