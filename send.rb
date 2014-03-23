
#! /usr/bin/ruby
require 'rest-client'
require 'csv'
def send_template_message
  RestClient.post "https://api:key-APIKEY"\ # Change APIKEY to your api key
  "@api.mailgun.net/v2/mail.teamail.biz/messages",
  :from => "Sample <sample@126.com>", # Change to whatever valid email address you want
  :to => recipients_emails,
  :subject => "新产品公告",
  :html => notification_text,

  # Change campaign name to your campaign,
  # Campaign is used to monitor mail sending status,
  # and it can be create in mailgun control panel.
  :"o:campaign" => 'CAMPNAME',
  :"recipient-variables" => recipient_variables(csv_contacts),
  :attachment => File.new("attachment.pdf") # Change this to your real attachments
end

class Recipient
  attr_reader :name, :email
  def initialize(name, email)
    @name = name
    @email = email
  end
end

def csv_contacts
  recipients = []
  CSV.foreach("test.csv") do |row|
    recipient = Recipient.new(row[0].strip,row[1].strip)
    recipients << recipient
  end
  recipients
end

def recipients_emails
  csv_contacts.map { |recipient| recipient.email }.join(",")
end

def recipient_variables(recipients)
  vars = recipients.map do |recipient|
    "\"#{recipient.email}\": {\"name\":\"#{recipient.name[0]}\"}"
  end
  "{#{vars.join(', ')}}"
end

def notification_text
  <<-EMAIL
  <HTML><body>
  <p>%recipient.name%老师,<p>
  <p>您好</p>
  <p>以下是本公司的产品目录，方面各位客户浏览，打包成pdf放在附件中了<p>
  <a href='https://teamail.biz'>产品网站</a>
  </body></html>
  EMAIL
end

send_template_message
