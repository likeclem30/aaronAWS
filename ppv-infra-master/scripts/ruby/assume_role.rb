require 'aws-sdk'

role_arn = ARGV[0]
session_name = ARGV[1]

if role_arn.nil? || session_name.nil?
  abort('Usage: ruby assume_role.rb ROLE_ARN SESSION_NAME')
end

sts = Aws::STS::Client.new(region: 'us-east-1')
resp = sts.assume_role(role_arn: role_arn,
                       role_session_name: session_name,)

creds = resp.credentials
puts "export AWS_ACCESS_KEY_ID=#{creds.access_key_id}"
puts "export AWS_SECRET_ACCESS_KEY=#{creds.secret_access_key}"
puts "export AWS_SESSION_TOKEN=#{creds.session_token}"
