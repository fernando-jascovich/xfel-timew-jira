# frozen_string_literal: true

require 'xfel/timew/jira'

RSpec.describe Xfel::Timew::Jira, '#initialize' do
  subject { described_class.new worklog }
  let(:worklog) { { start: 'A', duration: 23, key: 'IM-111' } }

  it 'sets @start' do
    expect(subject.instance_variable_get(:@start))
      .to eq(worklog[:start])
  end

  it 'sets @duration' do
    expect(subject.instance_variable_get(:@duration))
      .to eq(worklog[:duration])
  end

  it 'sets @key' do
    expect(subject.instance_variable_get(:@key)).to eq(worklog[:key])
  end
end

RSpec.describe Xfel::Timew::Jira, '#initialize without all env vars' do
  it 'logs error' do
    ENV['XFEL_JIRA_SYNC'] = '1'
    allow_any_instance_of(described_class).to receive(:log)
    inst = described_class.new({})
    expect(inst).to have_received(:log).with(
      'Missing required env vars: JIRA_HOST, JIRA_USER, JIRA_PASS'
    )
  end
end

RSpec.describe Xfel::Timew::Jira, '#initialize with all required vars' do
  subject do
    described_class.new worklog
  end

  let(:worklog) { { key: 'AAAAA' } }

  before do
    ENV['XFEL_JIRA_SYNC'] = '1'
    ENV['JIRA_HOST'] = 'a'
    ENV['JIRA_USER'] = 'b'
    ENV['JIRA_PASS'] = 'c'
    allow_any_instance_of(described_class)
      .to receive(:sync).and_return(nil)
  end

  after do
    ENV['XFEL_JIRA_SYNC'] = nil
  end

  it 'sets @uri' do
    uri = "#{ENV['JIRA_HOST']}/rest/api/2/issue/#{worklog[:key]}/worklog"
    expect(subject.instance_variable_get(:@uri)).to eq(uri)
  end

  it 'calls #sync' do
    allow(subject).to receive(:sync)
    expect(subject).to have_received(:sync)
  end
end

RSpec.describe Xfel::Timew::Jira, '#vars' do
  subject { described_class.new(worklog).vars }
  let(:worklog) { {} }

  it 'returns a string with notifyUsers' do
    expect(subject).to include('notifyUsers=false')
  end

  it 'returns a string with adjustEstimate' do
    expect(subject).to include('adjustEstimate=leave')
  end

  it 'returns a string with overrideEditableFlag' do
    expect(subject).to include('overrideEditableFlag')
  end
end

RSpec.describe Xfel::Timew::Jira, '#log' do
  subject do
    inst = described_class.new({})
    inst.instance_variable_set(:@key, key)
    inst
  end

  let(:key) { 'SOME' }

  before do
    allow(subject).to receive(:puts)
  end

  it 'puts expected message' do
    msg = 'something important here.'
    subject.log msg
    expected = "#{key} | #{msg}"
    expect(subject).to have_received(:puts).with(expected)
  end
end

RSpec.describe Xfel::Timew::Jira, '#sync' do
  subject { described_class.new({}) }

  before do
    allow(subject).to receive(:worklogs).and_return([1, 2, 3])

    response = OpenStruct.new({ code: '404', body: 'Not found' })
    allow(subject).to receive(:req_for_sync).and_return(response)
  end

  it 'does not call #req_for_sync for duplicated worklogs' do
    allow(subject).to receive(:duplicated?).and_return(true)
    subject.sync
    expect(subject).not_to have_received(:req_for_sync)
  end

  it 'does indeed call #req_for_sync for non-duplicated worklogs' do
    allow(subject).to receive(:duplicated?).and_return(false)
    subject.sync
    expect(subject).to have_received(:req_for_sync)
  end
end

RSpec.describe Xfel::Timew::Jira, '#req_success?' do
  subject { described_class.new({}).req_success?(response) }

  context 'with successful response' do
    let(:response) { OpenStruct.new({ code: 200 }) }

    it 'returns true' do
      expect(subject).to be(true)
    end
  end

  context 'without successful response' do
    let(:response) { OpenStruct.new({ code: 500 }) }

    it 'returns false' do
      expect(subject).to be(false)
    end
  end
end

RSpec.describe Xfel::Timew::Jira, '#req_for_sync' do
  include_context 'inst for req'

  it 'calls #execute with uri' do
    uri = URI("#{insturi}?#{vars}")
    expect(subject).to have_received(:execute).with(anything, uri)
  end

  it 'calls #execute with a request containing content type' do

  end
end
