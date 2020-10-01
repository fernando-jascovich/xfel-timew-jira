# frozen_string_literal: true

require 'xfel/timew/jira'

RSpec.describe Xfel::Timew::Jira, '#initialize' do
  subject { described_class.new worklog }
  let(:worklog) { { start: 'A', duration: 23, key: 'IM-111' } }

  it 'sets @start' do
    result = subject.instance_variable_get(:@start)
    expect(result).to eq(worklog[:start])
  end

  it 'sets @duration' do
    result = subject.instance_variable_get(:@duration)
    expect(result).to eq(worklog[:duration])
  end
end

RSpec.describe Xfel::Timew::Jira, '#vars' do
  subject { described_class.new(worklog).vars }
  let(:worklog) { {} }

  it 'returns hash with notifyUsers' do
    expect(subject[:notifyUsers]).to be false
  end

  it 'returns hash with adjustEstimate' do
    expect(subject[:adjustEstimate]).to eq 'leave'
  end

  it 'returns hash with overrideEditableFlag' do
    expect(subject[:overrideEditableFlag]).to be true
  end
end
