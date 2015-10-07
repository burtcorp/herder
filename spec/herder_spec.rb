require 'spec_helper'

describe Herder do
  let :herder do
    described_class.new(sns_client, job_flow_info_path: 'job-flow.json')
  end

  let :sns_client do
    double(:sns_client)
  end

  let :cluster_config do
    {
      'jobFlowId' => 'j-ABCDEFGHIJKLM',
    }
  end

  around do |example|
    Dir.mktmpdir do |path|
      Dir.chdir(path) do
        example.call
      end
    end
  end

  before do
    allow(sns_client).to receive(:publish)
  end

  before do
    File.open('job-flow.json', 'w') do |io|
      io.puts(JSON.pretty_generate(cluster_config))
    end
  end

  describe '#notify' do
    it 'publishes a message to the specified topic' do
      herder.notify('TOPIC_ARN', 'Job complete')
      expect(sns_client).to have_received(:publish).with(hash_including(topic_arn: 'TOPIC_ARN'))
    end

    it 'sets the subject to the specified string' do
      herder.notify('TOPIC_ARN', 'Job complete')
      expect(sns_client).to have_received(:publish).with(hash_including(subject: 'Job complete'))
    end

    it 'does not set the subject when none is specified' do
      herder.notify('TOPIC_ARN')
      expect(sns_client).to have_received(:publish).with(satisfy { |h| !h.include?(:subject) })
    end

    it 'sets the message to the EMR job flow ID' do
      herder.notify('TOPIC_ARN', 'Job complete')
      expect(sns_client).to have_received(:publish).with(hash_including(message: 'j-ABCDEFGHIJKLM'))
    end
  end
end
