require 'optparse'
require 'aws-sdk'
require 'json'

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
    new(Aws::SNS::Client.new).notify(topic_arn, subject)
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
end