task :send_out_emails => :environment do
  User.subscribed.find_each { |user| user.send_out_morning_email! }
end

task :archive_old_messages => :environment do
  Item.unarchived.older_than_in_days(3).find_each { |item| item.archive! }
end