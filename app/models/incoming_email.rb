class IncomingEmail < ActiveRecord::Base

  def self.process(email, body, subject)    
    if User.email_in_db?(email)
      user = User.find_by_email(email)
      line_array = body.split("\n")

      user.resubscribe! if line_array.include? "RESUBSCRIBE ME" || subject == "RESUBSCRIBE ME"
      user.unsubscribe! if line_array.include? "UNSUBSCRIBE ME" || subject == "UNUSUBSCRIBE ME"

      additions     = line_array.select{ |line| line[0] == "+" }
      subtractions  = line_array.select{ |line| line[0] == "-" }

      puts "ABOUT TO ADD/SUBTRACT"
      user.add_and_subtract_items!(additions, subtractions)
      puts "EMAIL THEORETICALLY PROCESSED"
    else
      UserMailer.must_subscribe(email).deliver
    end
  end
end