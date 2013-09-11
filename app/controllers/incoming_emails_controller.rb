class IncomingEmailsController < ApplicationController
  def receive
    sender  = params['from']
    subject = params['subject']

    body = params['stripped-text']

    IncomingEmail.process(sender, body, subject)

    puts "EMAIL RECEIVED"
    head 200
  end
end