class FlowMailer < ActionMailer::Base
  default from: "from@example.com"
  
  def flow_notify_email(overtime, user, subject)
    @overtime = overtime
    mail to: user.email, subject: subject
  end
end
