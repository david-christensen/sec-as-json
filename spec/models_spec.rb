# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'models' do
  it 'Filings.find_by_cik' do
    filings = Filings.find_by_cik('0001358706')
    expect(filings.count).to eq 3

    hedge_fund = filings.find {|f| f.is_a?(HedgeFund) }
    expect(hedge_fund.name).to eq 'ABRAMS CAPITAL MANAGEMENT, L.P.'

    tracked_filings = filings.select {|f| f.is_a?(TrackedFiling) }
    expect(tracked_filings.count).to eq 2
    expect(tracked_filings.select{|f| f['type'] == '4'}.count).to eq 1
    expect(tracked_filings.select{|f| f['type'] == '13F-HR'}.count).to eq 1
  end

  it 'HedgeFund.find' do
    fund = HedgeFund.find('0001358706')
    expect(fund).to be_a HedgeFund
    expect(fund.name).to eq 'ABRAMS CAPITAL MANAGEMENT, L.P.'
  end

  it 'TrackedFiling.find_by_cik' do
    filings = TrackedFiling.find_by_cik('0001358706')
    expect(filings.count).to eq 2
  end

  it 'TrackedFiling.where(...)' do
    tracked_form_4s = TrackedFiling.where(cik: '0001358706', type: '4').all
    expect(tracked_form_4s.count).to eq 1
    tracked_form_4 = tracked_form_4s.first
    expect(tracked_form_4).to be_a TrackedFiling
    expect(tracked_form_4.type).to eq '4'
    expect(tracked_form_4.metadata).to start_with 'tracked-filing-'
    expect(tracked_form_4.fundName).to eq 'ABRAMS CAPITAL MANAGEMENT, L.P.'
  end
end