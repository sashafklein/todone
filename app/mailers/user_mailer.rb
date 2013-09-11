class UserMailer < ActionMailer::Base

  default from: "Task Master <todo@todone.us>"

  def seeded_morning_email(user, items)
    @user = user
    @items = items
    mail to: @user.email, subject: "To(Get)Done - #{items.count} Items - #{Date.today_as_a_string}"
  end

  def blank_morning_email(user)
    @user = user
    mail to: @user.email, subject: "Blank Slate - #{Date.today_as_a_string}"
  end

  def unsubscribed(user)
    @user = user
    mail to: @user.email, subject: "Sorry to see you go!"
  end

  def failed_additions(user, item_array)
    @user = user
    @item_array = item_array

    mail to: @user.email, subject: "Failed Addition(s) - #{Date.today_as_a_string}"
  end

  def must_subscribe(email_address)
    @email = email_address
    mail to: email_address, subject: "Sorry - you must subscribe to do that!"
  end
end