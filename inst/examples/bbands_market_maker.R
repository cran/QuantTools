\donttest{

##################################
## Bollinger Bands Market Maker ##
##################################

# load tick data
data( 'ticks' )

# define strategy
strategy_source = system.file( package = 'QuantTools', 'examples/bbands_market_maker.cpp' )
# compile strategy
Rcpp::sourceCpp( strategy_source )

# set strategy parameters
parameters = data.table(
  n         = 100,
  k         = 0.5,
  timeframe = 60
)

# set options, see 'Options' section
options = list(
  cost    = list( tradeAbs = -0.01 ),
  latency = 0.1, # 100 milliseconds
  allow_limit_to_hit_market = TRUE
)

# run test
test_summary = bbands_market_maker( ticks, parameters, options, fast = TRUE )
print( test_summary )

# run test
test = bbands_market_maker( ticks, parameters, options, fast = FALSE )

# plot result
indicators = plot_dts(
test$indicators,
test$orders[ side == 'buy' , .( time_processed, buy  = price_exec ) ],
test$orders[ side == 'sell', .( time_processed, sell = price_exec ) ] )$
lines( c( 'lower', 'sma', 'upper' ) )$
lines( c( 'buy', 'sell' ), type = 'p', pch = c( 24, 25 ), col = c( 'blue', 'red' ) )

performance = plot_dts( test$indicators[, .( time, pnl = pnl * 100, drawdown = drawdown * 100 ) ] )$
lines( c( 'pnl', 'drawdown' ), c( '% pnl', '% drawdown' ), col = c( 'darkolivegreen', 'darkred' ) )

interval = '2016-01-19 12/13'
par( mfrow = c( 2, 1 ), oma = c( 5, 4, 2, 4 ) + 0.1, mar = c( 0, 0, 0, 0 ) )
indicators $limits( tlim = interval )$style( time = list( visible = FALSE ) )
performance$limits( tlim = interval )
title( 'Bollinger Bands On Limit Orders', outer = TRUE )
par( mfrow = c( 1, 1 ), oma = c( 0, 0, 0, 0 ), mar = c( 5, 4, 4, 2 ) + 0.1 )

}
