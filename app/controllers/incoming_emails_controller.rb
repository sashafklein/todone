class IncomingEmailsController < ApplicationController
  
  skip_before_filter :verify_authenticity_token
  
  def receive
    sender  = params['from']
    subject = params['subject']

    body = params['stripped-text']

    IncomingEmail.process(email: sender, body: body, subject: subject)

    head 200
  end
  
end