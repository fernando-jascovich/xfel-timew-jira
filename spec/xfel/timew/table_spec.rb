# frozen_string_literal: true

require 'xfel/timew/table'

RSpec.configure do |config|
  config.before(:example) do
    @spy = spy('Table')
    msgs = { add_row: nil, align_column: nil, add_separator: nil }
    allow(@spy).to receive_messages(msgs)
    allow(Terminal::Table)
      .to receive(:new)
      .and_return(@spy)
  end
end

RSpec.describe Xfel::Timew::Table, '#initialize' do
  subject { described_class.new }

  it 'initializes @data' do
    expect(subject.instance_variable_get(:@data)).to eq({})
  end

  it 'initializes @table' do
    expect(subject.instance_variable_get(:@table)).to eq(@spy)
  end
end

RSpec.describe Xfel::Timew::Table, '#time_str' do
  subject { described_class.new.time_str(seconds) }
  let(:seconds) { 123_456_789 }

  it 'produces expected string' do
    hours = seconds / 3600
    minutes = seconds / 60 % 60
    expected = format("#{hours}h %02dm", minutes)
    expect(subject).to eq(expected)
  end
end

RSpec.describe Xfel::Timew::Table, '#project_to_table' do
  subject { described_class.new }
  let(:project) { 'SOMEPROJECT' }
  let(:tickets) { { 'SSS-1': 1230, 'SSS-2': 656_566 } }

  before { subject.project_to_table(project, tickets) }

  it 'adds project row' do
    expect(subject.instance_variable_get(:@table))
      .to have_received(:add_row).with([project, '', ''])
  end

  it 'adds each ticket row' do
    tickets.each do |key, duration|
      expect(subject.instance_variable_get(:@table))
        .to have_received(:add_row)
        .with(["└── #{key}", subject.time_str(duration), ''])
    end
  end

  it 'adds total duration row' do
    total = tickets.values.reduce { |sum, i| sum + i }
    expect(subject.instance_variable_get(:@table))
      .to have_received(:add_row).with(['', '', subject.time_str(total)])
  end
end

RSpec.describe Xfel::Timew::Table, '#data_to_table' do
  subject { described_class.new }
  let(:data) { { 'SOME': [], 'Another': [1, 2] } }

  before do
    allow(subject).to receive(:project_to_table).and_return(1)
    allow(subject.instance_variable_get(:@table))
      .to receive_messages({ add_separator: nil, add_row: nil })
    subject.instance_variable_set(:@data, data)
    subject.data_to_table
  end

  it 'calls #project_to_table with every project in @data' do
    data.each do |project, tickets|
      expect(subject).to have_received(:project_to_table)
        .with(project, tickets)
    end
  end

  it 'adds separator between projects' do
    expect(subject.instance_variable_get(:@table))
      .to have_received(:add_separator).at_least(data.length).times
  end

  it 'adds total row' do
    expect(subject.instance_variable_get(:@table))
      .to have_received(:add_row)
      .with(['', '', subject.time_str(data.length)])
  end
end

RSpec.describe Xfel::Timew::Table, '#render' do
  subject { described_class.new }

  before do
    allow(subject).to receive_messages({ data_to_table: nil, puts: nil })
    allow(subject.instance_variable_get(:@table))
      .to receive(:align_column)
    subject.render
  end

  it 'calls #data_to_table' do
    expect(subject).to have_received(:data_to_table)
  end

  it 'aligns first table column to the right' do
    expect(subject.instance_variable_get(:@table))
      .to have_received(:align_column).with(1, :right)
  end

  it 'aligns second table column to the right' do
    expect(subject.instance_variable_get(:@table))
      .to have_received(:align_column).with(2, :right)
  end

  it 'calls puts' do
    expect(subject).to have_received(:puts)
      .with(subject.instance_variable_get(:@table))
  end
end

RSpec.describe Xfel::Timew::Table, '#add' do
  subject { described_class.new }
  let(:worklog) { { project: 'SOME', key: 'SOME-123', duration: 100 } }
  before { subject.add(worklog) }

  it 'adds @data entry' do
    expected = {}
    expected[worklog[:project]] = {}
    expected[worklog[:project]][worklog[:key]] = worklog[:duration]
    expect(subject.instance_variable_get(:@data)).to eq(expected)
  end
end
