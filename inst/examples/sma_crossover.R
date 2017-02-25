\dontrun{

# load tick data
data( 'ticks' )
# define strategy
strategy_source = system.file( package = 'QuantTools', 'examples/sma_crossover.cpp' )
# compile strategy
Rcpp::sourceCpp( strategy_source )
# set strategy parameters
parameters = data.table(
  period_fast = 50,
  period_slow = 30,
  timeframe   = 60
)
# set options, see 'Options' section
options = list(
  cost = list( tradeAbs = -0.01 ),
  latency = 0.1
)
# run test
test_summary = sma_crossover( ticks, parameters, options, fast = T )
print( test_summary )
# run test on single date
interval = '2016-09-08'
test = sma_crossover( ticks[ time %bw% '2016-09-08' ], parameters, options, fast = F )
# plot result
# leave only closed trades and executed orders
test$trades = test$trades[ state == 'closed' ]
test$orders = test$orders[ state == 'executed' ]

layout( matrix( 1:2, ncol = 1 ), height = c( 2, 1 ) )

par( mar = c( 0, 4, 2, 4 ), family = 'sans' )
par( xaxt = 'n' )
plot_ts( test$indicators[ time %bw% interval ], type = 'candle' )
plot_ts( test$indicators[ ,.( time, sma_slow, sma_fast ) ],
         col = c( 'goldenrod', 'darkmagenta' ), legend = 'topleft', add = T )
test$orders[, points( t_to_x( time_processed ), price_exec,
                     pch = ifelse( side == 'buy', 24, 25 ),
                     col = ifelse( side == 'buy', 'blue', 'red' ) )
]
par( xaxt = 's', mar = c( 4, 4, 0, 4 ) )
plot_ts( test$indicators[, .( time, `P&L, %` = pnl * 100, `Draw Down, %` = drawdown * 100 ) ],
         col = c( 'blue', 'red' ), legend = 'bottomleft' )


}
