# frozen_string_literal: true

require 'xfel/timew/report'

RSpec.configure do |config|
  config.before(:example, { input: false }) do
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

  context 'without input from #read', { input: false } do
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
      .to receive(:gets)
      .and_return(' ', '{}', nil, ' ', json_str, nil)
  end

  subject { described_class.new }

  it 'returns provided json (as TimeWarrior docs)' do
    expect(subject.read).to eq(JSON.parse(json_str))
  end
end
