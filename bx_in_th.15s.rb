#!/usr/bin/env ruby

require 'net/http'
require 'json'

# See pairing id at https://bx.in.th/api/pairing/
#PAIRING_ID = 26 # THB-OMG
#PAIRING_ID = 1 # THB-BTC
PAIRING_ID = 21 # THB-ETH

def fx
  url = 'http://api.fixer.io/latest?symbols=THB&base=USD'
  response = Net::HTTP.get(URI(url))
  data = JSON.parse(response)['rates']['THB']
end

def coinbase_price
  url = 'https://api.coinbase.com/v2/prices/ETH-USD/spot'
  response = Net::HTTP.get(URI(url))
  data = JSON.parse(response)['data']['amount']
end

def run
  url = 'https://bx.in.th/api/'
  response = Net::HTTP.get(URI(url))
  data = JSON.parse(response)[PAIRING_ID.to_s]

  output(data, fx, coinbase_price)
end

def output(d, fx, coinbase_price)
  primary = d['primary_currency']
  secondary = d['secondary_currency']
  last_price = d['last_price']
  last_price_usd = d['last_price'] / fx
  change = d['change']
  order_book = d['orderbook']
  bids = order_book['bids']
  asks = order_book['asks']


  summary = "#{primary}-#{secondary} @ #{last_price} (#{change}%) ~(#{'%.2f' % last_price_usd} vs Coinbase: #{coinbase_price}) USD"
  details = [
    "---",
    "24h volume : #{d['volume_24hours']} #{secondary}",
    "---",
    "Buy orders (Bids) @ #{bids['highbid']} #{secondary}",
    "Volume : #{bids['volume']} #{secondary}",
    "Total : #{bids['total']} orders",
    "---",
    "Sell orders (Asks) @ #{asks['highbid']} #{secondary}",
    "Volume : #{asks['volume']} #{secondary}",
    "Total : #{asks['total']} orders",
    "---",
    "Go to bx.in.th | href=https://bx.in.th color=black",
  ]

  [
    summary,
    *details,
  ].each(&method(:puts))
end

begin
  run
rescue StandardError => msg
  puts "Error occurred : #{msg}"
end
