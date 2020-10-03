# frozen_string_literal: true

require 'xfel/timew/report'

RSpec.configure do |config|
  config.before do
    allow($stdout).to receive(:puts)
  end

  config.before(:example) do
    allow_any_instance_of(described_class)
      .to receive(:read)
      .and_return([])
  end

  config.before(:example, { input: true }) do
    allow_any_instance_of(described_class)
      .to receive(:read)
      .and_return([{}])
  end
end

RSpec.describe Xfel::Timew::Report, '#initialize without input' do
  let(:table) { spy('Table') }

  before do
    allow(table).to receive_messages({ render: nil, add: nil })
    allow(Xfel::Timew::Table).to receive(:new).and_return(table)
  end

  context 'without input from #read' do
    before { described_class.new }

    it 'creates a new Table instance' do
      expect(Xfel::Timew::Table).to have_received(:new)
    end

    it 'calls table.render' do
      expect(table).to have_received(:render)
    end
  end

  context 'with nil input from #read', { input: true } do
    before do
      allow_any_instance_of(described_class).to receive(:convert).and_return(nil)
    end

    it 'does not include nil worklog on table' do
      expect(table).to_not have_received(:add)
    end
  end
end

RSpec.describe Xfel::Timew::Report, '#initialize with input' do
  let(:table) { spy('Table') }
  let(:worklog) { { some: 'thing' } }

  context 'with input', { input: true } do
    before do
      allow(table).to receive_messages({ render: nil, add: nil })
      allow(Xfel::Timew::Table).to receive(:new).and_return(table)
      allow_any_instance_of(described_class)
        .to receive(:convert)
        .and_return(worklog)
    end

    it 'passes worklog to table' do
      described_class.new
      expect(table).to have_received(:add).with(worklog)
    end

    it 'passes worklog to Jira.new' do
      allow(Xfel::Timew::Jira).to receive(:new)
      described_class.new
      expect(Xfel::Timew::Jira).to have_received(:new).with(worklog)
    end
  end
end

RSpec.describe Xfel::Timew::Report, '#read' do
  let(:json_str) { '{"some":"joe"}' }
  before do
    allow_any_instance_of(described_class)
      .to receive(:read)
      .and_call_original
    allow_any_instance_of(described_class)
      .to receive(:gets)
      .and_return(' ', '{}', nil, ' ', json_str, nil)
  end

  subject { described_class.new }

  it 'returns provided json (as TimeWarrior docs)' do
    expect(subject.read).to eq(JSON.parse(json_str))
  end
end

RSpec.describe Xfel::Timew::Report, '#key_from_tags' do
  subject { described_class.new }

  it 'returns nil by default' do
    expect(subject.key_from_tags([])).to be(nil)
  end

  it 'returns first match' do
    key = 'SOME-12'
    tags = ['some', key, 'ANOTHER-33']
    expect(subject.key_from_tags(tags)).to eq(key)
  end
end

RSpec.describe Xfel::Timew::Report, '#project_from_key' do
  subject { described_class.new.project_from_key(key) }
  let(:key) { 'JIRA-9999' }

  it 'returns first part of a hyphen-separated string' do
    expect(subject).to eq(key.split('-')[0])
  end
end

RSpec.describe Xfel::Timew::Report, '#convert' do
  subject { described_class.new.convert(item) }

  context 'without key' do
    let(:item) { {} }

    it 'returns nil' do
      expect(subject).to be(nil)
    end
  end

  context 'without end' do
    let(:item) { { tags: %w[KEY-1] } }

    it 'returns nil' do
      expect(subject).to be(nil)
    end
  end

  context 'with data' do
    let(:item) do
      {
        'tags' => %w[KEY-222 other 123123 x],
        'end' => '2020-01-02',
        'start' => '2020-01-01'
      }
    end

    it 'returns an object with .project' do
      expect(subject[:project]).to eq('KEY')
    end
  end
end
