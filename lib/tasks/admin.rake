namespace :admin do
  desc "Add an admin user"
  task :create do
    admin_password = ENV['ADMIN_PASS']
    create_code = <<-EOF
    admin = User.new(:email => "admin@admin.com", :password => "#{admin_password}")
    admin.roles = [:admin]
    admin.save!
    EOF
    sh "rails runner '#{create_code}'"
  end
end
