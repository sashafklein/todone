class IncomingEmailsController < ApplicationController
  def receive
    sender  = params['from']
    subject = params['subject']

    body = params['stripped-text']

    IncomingEmail.process(sender, body, subject)

    head 200
  end
end