require 'optparse'
require 'aws-sdk'
require 'json'
require 'open-uri'

class Herder
  def initialize(sns_client, options={})
    @sns_client = sns_client
    @job_flow_info_path = options[:job_flow_info_path] || '/mnt/var/lib/info/job-flow.json'
  end

  def self.run(argv)
    topic_arn = nil
    subject = nil
    parser = OptionParser.new do |parser|
      parser.on('--topic-arn ARN') { |a| topic_arn = a }
      parser.on('--subject STR') { |s| subject = s }
    end
    parser.parse(argv)
    new(sns_client).notify(topic_arn, subject)
  end

  def notify(topic_arn, subject=nil)
    config = {:topic_arn => topic_arn, :message => job_flow_id}
    config[:subject] = subject if subject
    @sns_client.publish(config)
  end

  private

  def job_flow_id
    JSON.load(File.read(@job_flow_info_path)).fetch('jobFlowId')
  end

  def self.sns_client
    options = {}
    unless ENV['AWS_REGION'] || ENV['AWS_DEFAULT_REGION']
      options[:region] = open('http://169.254.169.254/latest/meta-data/placement/availability-zone').read.chop
    end
    Aws::SNS::Client.new(options)
  end
end
