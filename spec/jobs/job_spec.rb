require 'rails_helper'

describe Job do
  describe '.enqueue' do
    let(:args) { {key: 'value'} }
    let(:job)  { double('job') }

    it 'adds the job to the delayed job queue' do
      expect(Job).to receive(:new).with(args).and_return(job)
      expect(Delayed::Job).to receive(:enqueue).with(job)
      Job.enqueue(args)
    end
  end
end
