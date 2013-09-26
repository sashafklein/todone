class IncomingEmail < ActiveRecord::Base

  def self.process(options)
    email = options[:email].strip_email
    line_array = options[:body].split("\n")
    subject = options[:subject]

    if User.email_in_db?(email)
      user = User.find_by_email(email)

      user.resubscribe! if line_array.include?("RESUBSCRIBE ME") || subject == "RESUBSCRIBE ME"
      user.unsubscribe! if line_array.include?("UNSUBSCRIBE ME") || subject == "UNSUBSCRIBE ME"

      subtractions  = line_array.select{ |line| line[0] == "-" }
      additions     = line_array.select{ |line| line[0] == "+" }

      user.add_and_subtract_items!(additions, subtractions)
    else
      UserMailer.must_subscribe(email).deliver
    end
  end
end