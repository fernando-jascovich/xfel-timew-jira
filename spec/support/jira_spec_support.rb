# frozen_string_literal: true

shared_context 'inst for req' do
  subject do
    inst = described_class.new({})
    inst.instance_variable_set(:@uri, insturi)
    inst.instance_variable_set(:@start, start)
    inst.instance_variable_set(:@duration, duration)
    inst
  end

  let(:vars) { 'some=vars' }
  let(:insturi) { '/some/path' }
  let(:start) { 1 }
  let(:duration) { 100 }

  before do
    allow(subject).to receive(:vars).and_return(vars)
    allow(subject).to receive(:execute).and_return(nil)
    allow(Net::HTTP::Post).to receive(:new).and_return(OpenStruct.new)
    subject.req_for_sync
  end
end
