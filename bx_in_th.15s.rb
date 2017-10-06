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

def bitfinex_price
  url= 'https://api.bitfinex.com/v1/pubticker/ethusd'
  response = Net::HTTP.get(URI(url))
  data = JSON.parse(response)['last_price']
end

def coinbase_price
  url = 'https://api.coinbase.com/v2/prices/ETH-USD/spot'
  response = Net::HTTP.get(URI(url))
  data = JSON.parse(response)['data']['amount']
end

def poloniex_price
  url = 'https://poloniex.com/public?command=returnTicker'
  response = Net::HTTP.get(URI(url))
  data = JSON.parse(response)['USDT_ETH']['last']
end

def kraken_price
  url = 'https://api.kraken.com/0/public/Ticker?pair=ETHUSD'
  response = Net::HTTP.get(URI(url))
  data = JSON.parse(response)['result']['XETHZUSD']['c'][0]
end

def run
  url = 'https://bx.in.th/api/'
  response = Net::HTTP.get(URI(url))
  data = JSON.parse(response)[PAIRING_ID.to_s]

  output(data)
end

def output(d)
  primary = d['primary_currency']
  secondary = d['secondary_currency']
  last_price = r(d['last_price'])
  last_price_usd = d['last_price'] / fx
  change = d['change']
  order_book = d['orderbook']
  bids = order_book['bids']
  asks = order_book['asks']

  summary = "#{secondary} @#{last_price} (BX: #{r(last_price_usd)}, C: #{r(coinbase_price)}, BF: #{r(bitfinex_price)}, K: #{r(kraken_price)} USD) #{Time.now.strftime("%H:%M:%S")}"
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

def r(value)
  "%g" % value.to_f.round(2)
end

begin
  run
rescue StandardError => msg
  puts "Error occurred : #{msg}"
end
