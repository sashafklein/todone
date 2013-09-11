class IncomingEmailsController < ApplicationController
  def receive
    # process various message parameters:
    sender  = params['from']
    subject = params['subject']

    # get the "stripped" body of the message, i.e. without
    # the quoted part
    body = params["stripped-text"]

    # process all attachments:
    UserMailer.email_working(body).deliver
  end
end