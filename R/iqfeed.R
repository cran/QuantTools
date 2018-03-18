# Copyright (C) 2016 Stanislav Kovalevsky
#
# This file is part of QuantTools.
#
# QuantTools is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# QuantTools is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with QuantTools. If not, see <http://www.gnu.org/licenses/>.

#' IQFeed
#'
#' @name iqfeed
#' @examples
#' \donttest{
#' symbol = 'MSFT'
#' to = format( Sys.time() )
#' from = format( Sys.time() - as.difftime( 3, units = 'days' ) )
#' days = 10
#' # ticks
#' get_iqfeed_data( symbol, from, to, 'tick' )
#' # candles
#' get_iqfeed_data( symbol, from, to, '1min' )
#' # daily candles
#' get_iqfeed_data( symbol, from, to )
#' }
#'
#' @details Retrieves IQFeed historical market data like ticks and candles.
#'
#' @section Basis For Last:
#' \tabular{ll}{
#' C \tab Last Qualified Trade                                  \cr
#' E \tab Extended Trade = Form T trade                         \cr
#' O \tab Other Trade = Any trade not accounted for by C or E.  \cr
#' S \tab Settle = Daily settle, only applicable to commodities.
#' }
#'
#' @section Markets:
#' \tabular{lll}{
#' \strong{Market Id} \tab \strong{Short Name}  \tab \strong{Long Name}                  \cr
#'   1      \tab NGM         \tab Nasdaq Global Market                                   \cr
#'   2      \tab NCM         \tab National Capital Market                                \cr
#'   3      \tab OTC         \tab Nasdaq other OTC                                       \cr
#'   4      \tab OTCBB       \tab Nasdaq OTC Bulletin Board                              \cr
#'   5      \tab NASDAQ      \tab Nasdaq                                                 \cr
#'   6      \tab NYSE_MKT    \tab NYSE MKT (Equities and Bonds)                          \cr
#'   7      \tab NYSE        \tab New York Stock Exchange                                \cr
#'   8      \tab CHX         \tab Chicago Stock Exchange                                 \cr
#'   9      \tab PHLX        \tab Philadelphia Stock Exchange                            \cr
#'  10      \tab NSX         \tab National Stock Exchange                                \cr
#'  11      \tab NYSE_ARCA   \tab NYSE Archipelago                                       \cr
#'  12      \tab BX          \tab Boston Stock Exchange                                  \cr
#'  13      \tab CBOE        \tab Chicago Board Options Exchange                         \cr
#'  14      \tab OPRA        \tab OPRA System                                            \cr
#'  15      \tab NASD_ADF    \tab Nasdaq Alternate Display facility                      \cr
#'  16      \tab ISE         \tab International Stock Exchange                           \cr
#'  17      \tab BOX         \tab Boston Options Exchange                                \cr
#'  18      \tab BATS        \tab Better Alternative Trading System                      \cr
#'  19      \tab NTRF        \tab Nasdaq Trade Reporting Facility                        \cr
#'  20      \tab PBOT        \tab Philadelphia Board Of Trade                            \cr
#'  21      \tab NGSM        \tab Nasdaq Global Select Market                            \cr
#'  22      \tab CANTOR      \tab Cantor Fitzgerald Exchange Treasury Funds              \cr
#'  23      \tab C2          \tab CBOE C2 Options Exchange                               \cr
#'  24      \tab NYSE_TRF    \tab NYSE Trade Reporting Facility                          \cr
#'  25      \tab EDGA        \tab Direct Edge A                                          \cr
#'  26      \tab EDGX        \tab Direct Edge X                                          \cr
#'  27      \tab DTN         \tab DTN                                                    \cr
#'  28      \tab BYX         \tab BATS Y Exchange                                        \cr
#'  29      \tab RUSSELL-FL  \tab Russell Investments (Fee-Liable)                       \cr
#'  30      \tab CBOT        \tab Chicago Board Of Trade                                 \cr
#'  31      \tab DJ          \tab Dow Jones (CBOT)                                       \cr
#'  32      \tab CFE         \tab CBOE Futures Exchange                                  \cr
#'  33      \tab KCBOT       \tab Kansas City Board Of Trade                             \cr
#'  34      \tab CME         \tab Chicago Mercantile Exchange                            \cr
#'  35      \tab MGE         \tab Minneapolis Grain Exchange                             \cr
#'  36      \tab NYMEX       \tab New York Mercantile Exchange                           \cr
#'  37      \tab COMEX       \tab Commodities Exchange Center                            \cr
#'  38      \tab ICEFU       \tab International Commodities Exchange Futures US          \cr
#'  39      \tab NYLUS       \tab NYSE LIFFE US                                          \cr
#'  40      \tab CME-FL      \tab CME Indexes (Fee Liable)                               \cr
#'  42      \tab CBOTMINI    \tab Chicago Board Of Trade Mini Sized Contracts            \cr
#'  43      \tab CMEMINI     \tab Chicago Mercantile Exchange Mini Sized Contracts       \cr
#'  44      \tab USFE        \tab US Futures Exchange                                    \cr
#'  45      \tab NYMEXMINI   \tab Commodities Exchange Center Mini Sized Contracts       \cr
#'  46      \tab GREENX      \tab The Green Exchange                                     \cr
#'  47      \tab CLEARPORT   \tab New York Mercantile Exchange                           \cr
#'  48      \tab COMEXMINI   \tab New York Mercantile Exchange Mini Sized Contracts      \cr
#'  50      \tab TSE         \tab Toronto Stock Exchange                                 \cr
#'  51      \tab MSE         \tab Montreal Stock Exchange                                \cr
#'  52      \tab CVE         \tab Canadian Venture Exchange                              \cr
#'  53      \tab WSE         \tab Winnipeg Stock Exchange                                \cr
#'  54      \tab ICEFC       \tab International Commodities Exchange Futures Canada      \cr
#'  55      \tab MX          \tab Montreal Exchange                                      \cr
#'  56      \tab LSE         \tab London Stock Exchange                                  \cr
#'  57      \tab FTSE        \tab Financial Times Stock Exchange                         \cr
#'  60      \tab MDEX        \tab Bursa Malaysia Derivatives                             \cr
#'  61      \tab ICEFI       \tab International Commodities Exchange Futures Derivatives \cr
#'  62      \tab LME         \tab London Metals Exchange                                 \cr
#'  63      \tab ICEEC       \tab International Commodities Exchange European Commodities\cr
#'  64      \tab ASXCM       \tab ASX24 Commodities Exchange                             \cr
#'  65      \tab DME         \tab Dubai Mercantile Exchange                              \cr
#'  66      \tab BMF         \tab Brazilian Mercantile & Future Exchange                 \cr
#'  67      \tab SGX         \tab Singapore International Monetary Exchange              \cr
#'  68      \tab EUREX       \tab European Exchange                                      \cr
#'  69      \tab ENID        \tab Euronext Index Derivatives                             \cr
#'  70      \tab ICEEF       \tab International Commodities Exchange European Financials \cr
#'  71      \tab ENCOM       \tab Euronext Commodities                                   \cr
#'  72      \tab TULLETT     \tab Tullett Liberty (Forex)                                \cr
#'  73      \tab BARCLAYS    \tab Barclays Bank (Forex)                                  \cr
#'  74      \tab FXCM        \tab Forex Capital Markets                                  \cr
#'  75      \tab WTB         \tab Warenterminborse Hannover                              \cr
#'  76      \tab MGKB        \tab MGE-KCBOT (InterCommodity Spreads)                     \cr
#'  77      \tab MGCB        \tab MGE-CBOT (InterCommodity Spreads)                      \cr
#'  78      \tab TENFORE     \tab Tenfore Systems                                        \cr
#'  79      \tab NYDME       \tab NYMEX-DME (InterCommodity Spreads)                     \cr
#'  80      \tab PSX         \tab Philadelphia Stock Exchange                            \cr
#'  81      \tab TGE         \tab Tokyo Grain Exchange                                   \cr
#'  82      \tab TOCOM       \tab Tokyo Commodities Exchange                             \cr
#'  83      \tab SAFEX       \tab South African Futures Exchange                         \cr
#'  84      \tab EEXP        \tab European Energy Exchange - Power                       \cr
#'  85      \tab EEXN        \tab European Energy Exchange - Natural Gas                 \cr
#'  86      \tab EEXE        \tab European Energy Exchange - Emission Rights             \cr
#'  87      \tab EEXC        \tab European Energy Exchange - Coal                        \cr
#'  88      \tab MIAX        \tab Miami International Securities Exchange                \cr
#'  89      \tab KBCB        \tab KCBOT-CBOT (InterCommodity Spreads)                    \cr
#'  90      \tab PK_SHEETS   \tab Pink Sheets - No Tier                                  \cr
#'  91      \tab PK_QXPREM   \tab Pink Sheets - OTCQX - PremierQX Tier                   \cr
#'  92      \tab PK_QXPRIME  \tab Pink Sheets - OTCQX - PrimeQX Tier                     \cr
#'  93      \tab PK_IQXPREM  \tab Pink Sheets - OTCQX - International PremierQX Tier     \cr
#'  94      \tab PK_IQXPRIME \tab Pink Sheets - OTCQX - International PrimeQX Tier       \cr
#'  95      \tab PK_OTCQB    \tab Pink Sheets - OTCBB Pink Sheets dually Quoted Tier     \cr
#'  96      \tab PK_BBONLY   \tab Pink Sheets - OTCBB Only Tier                          \cr
#'  97      \tab PK_CURRENT  \tab Pink Sheets - Current Tier                             \cr
#'  98      \tab PK_LIMITED  \tab Pink Sheets - Limited Tier                             \cr
#'  99      \tab PK_NOINFO   \tab Pink Sheets - No Information Tier                      \cr
#' 100      \tab PK_GREY     \tab Pink Sheets - Grey Market Tier                         \cr
#' 101      \tab PK_YL_SHEETS\tab Yellow Sheets                                          \cr
#' 102      \tab PK_PR_SHEETS\tab Partner Sheets                                         \cr
#' 103      \tab PK_GL_SHEETS\tab Global Sheets                                          \cr
#' 104      \tab PK_NYSE     \tab Pink Sheets - NYSE Listed                              \cr
#' 105      \tab PK_NASDAQ   \tab Pink Sheets - NASDAQ Listed                            \cr
#' 106      \tab PK_NYSE_AMEX\tab Pink Sheets - NYSE AMEX Listed                         \cr
#' 107      \tab PK_ARCA     \tab Pink Sheets - ARCA Listed                              \cr
#' 108      \tab NYSE_AMEX   \tab NYSE AMEX Options Exchange                             \cr
#' 109      \tab GLOBEX_RT   \tab CME GLOBEX Group Authorization                         \cr
#' 110      \tab CME_GBX     \tab Chicago Mercantile Exchange (GLOBEX)                   \cr
#' 111      \tab CBOT_GBX    \tab Chicago Board Of Trade (GLOBEX)                        \cr
#' 112      \tab NYMEX_GBX   \tab New York Mercantile Exchange (GLOBEX)                  \cr
#' 113      \tab COMEX_GBX   \tab Commodities Exchange Center (GLOBEX)                   \cr
#' 114      \tab DME_GBX     \tab Dubai Mercantile Exchange (GLOBEX)                     \cr
#' 115      \tab RUSSELL     \tab Russell Investments                                    \cr
#' 116      \tab BZX         \tab BATS Z Exchange                                        \cr
#' 117      \tab CFTC        \tab US Commodity Futures Trading Commission                \cr
#' 118      \tab USDA        \tab US Department of Agriculture                           \cr
#' 119      \tab WASDE       \tab World Supply and Demand Estimates Report               \cr
#' 120      \tab GRNST       \tab Grain Stock Report                                     \cr
#' 121      \tab GEMINI      \tab ISE Gemini Options Exchange                            \cr
#' 122      \tab ARGUS       \tab Argus Energy                                           \cr
#' 123      \tab RACKS       \tab Racks Energy                                           \cr
#' 124      \tab SNL         \tab SNL Energy                                             \cr
#' 125      \tab RFSPOT      \tab Refined Fuels Spots Exchange                           \cr
#' 126      \tab EOXNGF      \tab EOX Live Natural Gas Forward Curve                     \cr
#' 127      \tab EOXPWF      \tab EOX Live Power Forward Curve                           \cr
#' 128      \tab EOXCOR      \tab EOX Live Correlations                                  \cr
#' 129      \tab ICEENDEX    \tab ICE Energy Derivatives Exchange                        \cr
#' 130      \tab KCBOT_GBX   \tab Kansas City Board of Trade (GLOBEX)                    \cr
#' 131      \tab MGE_GBX     \tab Minneapolis Grain Exchange (GLOBEX)                    \cr
#' 132      \tab BLOOMBERG   \tab Bloomberg Indices                                      \cr
#' 133      \tab ELSPOT      \tab Nord Pool Spot                                         \cr
#' 134      \tab N2EX        \tab NASDAQ OMX-Nord Pool                                   \cr
#' 135      \tab ICEEA       \tab International Commodities Exchange European Agriculture\cr
#' 136      \tab CMEUR       \tab Chicage Mercantile Exchange Europe Ltd                 \cr
#' 137      \tab COMM3       \tab Commodity 3 Exchange                                   \cr
#' 138      \tab JACOBSEN    \tab The Jacobsen                                           \cr
#' 139      \tab NFX         \tab NASDAQ OMX Futures                                     \cr
#' 140      \tab SGXAC       \tab SGX Asia Clear                                         \cr
#' 141      \tab PJMISO      \tab Pa-Nj-Md Independent System Operator                   \cr
#' 142      \tab NYISO       \tab New York Independent System Operator                   \cr
#' 143      \tab NEISO       \tab New England Independent System Operator                \cr
#' 144      \tab MWISO       \tab Mid West Independent System Operator                   \cr
#' 145      \tab SPISO       \tab SW Power Pool Independent System Operator              \cr
#' 146      \tab CAISO       \tab California Independent System Operator                 \cr
#' 147      \tab ERCOT       \tab ERCOT Independent System Operator                      \cr
#' 148      \tab ABISO       \tab Alberta Independent System Operator                    \cr
#' 149      \tab ONISO       \tab Ontario Independent System Operator                    \cr
#' 150      \tab MERCURY     \tab ISE Mercury Options Exchange                           \cr
#' 151      \tab DCE         \tab Dalian Commodity Exchange                              \cr
#' 152      \tab ZCE         \tab Zengchou Commodity Exchange                            \cr
#' 153      \tab IEX         \tab Investors Exchange LLC                                 \cr
#' 154      \tab MCX         \tab Multi Commodity Exchange of India Limited              \cr
#' 155      \tab NCDEX       \tab National Commodity Exchange of India Limited           \cr
#' 156      \tab PEARL       \tab MIAX PEARL Options exchange                            \cr
#' 157      \tab CTS         \tab CTS System                                             \cr
#' 158      \tab LSEI        \tab London Stock Exchange International                    \cr
#' 159      \tab UNKNOWN     \tab Unknown Market
#' }
#' * to retireve above table use \code{QuantTools:::.get_iqfeed_markets_info()}
#'
#' @section Trade Conditions:
#' \tabular{lll}{
#' \strong{Condition Code} \tab \strong{Short Name}      \tab \strong{Description}                                                    \cr
#' 01            \tab REGULAR         \tab Normal Trade                                                                               \cr
#' 02            \tab ACQ             \tab Acquisition                                                                                \cr
#' 03            \tab CASHM           \tab Cash Only Market                                                                           \cr
#' 04            \tab BUNCHED         \tab Bunched Trade                                                                              \cr
#' 05            \tab AVGPRI          \tab Average Price Trade                                                                        \cr
#' 06            \tab CASH            \tab Cash Trade (same day clearing)                                                             \cr
#' 07            \tab DIST            \tab Distribution                                                                               \cr
#' 08            \tab NEXTDAY         \tab Next Day Market                                                                            \cr
#' 09            \tab BURSTBSKT       \tab Burst Basket Execution                                                                     \cr
#' 0A            \tab BUNCHEDSOLD     \tab Bunched Sold Trade                                                                         \cr
#' 0B            \tab ORDETAIL        \tab Opening/Reopening Trade Detail                                                             \cr
#' 0C            \tab INTERDAY        \tab Intraday Trade Detail                                                                      \cr
#' 0D            \tab BSKTONCLOSE     \tab Basket Index on Close                                                                      \cr
#' 0E            \tab RULE127         \tab Rule - 127 Trade NYSE                                                                      \cr
#' 0F            \tab RULE155         \tab Rule - 155 Trade AMEX                                                                      \cr
#' 10            \tab SOLDLAST        \tab Sold Last (late reporting)                                                                 \cr
#' 11            \tab NEXTDAYCLR      \tab Next Day Clearing                                                                          \cr
#' 12            \tab LATEREP         \tab Opened - Late Report of Opening Trade (in or out of sequence)                              \cr
#' 13            \tab PRP             \tab Prior Reference Price                                                                      \cr
#' 14            \tab SELLER          \tab Seller                                                                                     \cr
#' 15            \tab SPLIT           \tab Split Trade                                                                                \cr
#' 16            \tab RSVD            \tab (Reserved)                                                                                 \cr
#' 17            \tab FORMT           \tab Form-T Trade                                                                               \cr
#' 18            \tab CSTMBSKTX       \tab Custom Basket Cross                                                                        \cr
#' 19            \tab SOLDOSEQ        \tab Sold Out of Sequence                                                                       \cr
#' 1A            \tab CANC            \tab Cancelled Previous Transaction                                                             \cr
#' 1B            \tab CANCLAST        \tab Cancelled Last Transaction                                                                 \cr
#' 1C            \tab CANCOPEN        \tab Cancelled Open Transaction                                                                 \cr
#' 1D            \tab CANCONLY        \tab Cancelled Only Transaction                                                                 \cr
#' 1E            \tab OPEN            \tab Late Report of Opening Trade - out of sequence                                             \cr
#' 1F            \tab OPNL            \tab Late Report of Opening Trade - in correct sequence                                         \cr
#' 20            \tab AUTO            \tab Transaction Executed Electronically                                                        \cr
#' 21            \tab HALT            \tab Halt                                                                                       \cr
#' 22            \tab DELAYED         \tab Delayed                                                                                    \cr
#' 23            \tab NON_BOARDLOT    \tab NON_BOARDLOT                                                                               \cr
#' 24            \tab POSIT           \tab POSIT                                                                                      \cr
#' 25            \tab REOP            \tab Reopen After Halt                                                                          \cr
#' 26            \tab AJST            \tab Contract Adjustment for Stock Dividend - Split - etc.                                      \cr
#' 27            \tab SPRD            \tab Spread - Trade in Two Options in the Same Class (a buy and a sell in the same class)       \cr
#' 28            \tab STDL            \tab Straddle - Trade in Two Options in the Same Class (a buy and a sell in a put and a call)   \cr
#' 29            \tab STPD            \tab Follow a Non-stopped Trade                                                                 \cr
#' 2A            \tab CSTP            \tab Cancel Stopped Transaction                                                                 \cr
#' 2B            \tab BWRT            \tab Option Portion of a Buy/Write                                                              \cr
#' 2C            \tab CMBO            \tab Combo - Trade in Two Options in the Same Options Class (a buy and a sell in the same class)\cr
#' 2D            \tab UNSPEC          \tab Unspecified                                                                                \cr
#' 2E            \tab MC_OFCLCLOSE    \tab Market Center Official Closing Price                                                       \cr
#' 2F            \tab STPD_REGULAR    \tab Stopped Stock - Regular Trade                                                              \cr
#' 30            \tab STPD_SOLDLAST   \tab Stopped Stock - Sold Last                                                                  \cr
#' 31            \tab STPD_SOLDOSEQ   \tab Stopped Stock - Sold out of sequence                                                       \cr
#' 32            \tab BASIS           \tab Basis                                                                                      \cr
#' 33            \tab VWAP            \tab Volume-Weighted Average Price                                                              \cr
#' 34            \tab STS             \tab Special Trading Session                                                                    \cr
#' 35            \tab STT             \tab Special Terms Trading                                                                      \cr
#' 36            \tab CONTINGENT      \tab Contingent Order                                                                           \cr
#' 37            \tab INTERNALX       \tab Internal Cross                                                                             \cr
#' 38            \tab MOC             \tab Market On Close Trade                                                                      \cr
#' 39            \tab MC_OFCLOPEN     \tab Market Center Official Opening Price                                                       \cr
#' 3A            \tab FORTMTSOLDOSEQ  \tab Form-T Sold Out of Sequence                                                                \cr
#' 3B            \tab YELLOWFLAG      \tab Yellow Flag                                                                                \cr
#' 3C            \tab AUTOEXEC        \tab Auto Execution                                                                             \cr
#' 3D            \tab INTRMRK_SWEEP   \tab Intramaket Sweep                                                                           \cr
#' 3E            \tab DERIVPRI        \tab Derivately Priced                                                                          \cr
#' 3F            \tab REOPNING        \tab Re-Opeing Prints                                                                           \cr
#' 40            \tab CLSING          \tab Closing Prints                                                                             \cr
#' 41            \tab CAP_ELCTN       \tab CAP (Conversion and Parity) election trade                                                 \cr
#' 42            \tab CROSS_TRADE     \tab Cross Trade                                                                                \cr
#' 43            \tab PRICE_VAR       \tab Price Variation                                                                            \cr
#' 44            \tab STKOPT_TRADE    \tab Stock-Option Trade                                                                         \cr
#' 45            \tab SPIM            \tab stopped at price that did not constitute a Trade-Through                                   \cr
#' 46            \tab BNMT            \tab Benchmark Trade                                                                            \cr
#' 47            \tab TTEXEMPT        \tab Transaction is Trade Through Exempt                                                        \cr
#' 48            \tab LATE            \tab Late Market                                                                                \cr
#' 49            \tab XCHG_PHYSICAL   \tab Exchange for Physical                                                                      \cr
#' 4A            \tab CABINET         \tab Cabinet                                                                                    \cr
#' 4B            \tab DIFFERENTIAL    \tab Differential                                                                               \cr
#' 4C            \tab HIT             \tab Hit                                                                                        \cr
#' 4D            \tab IMPLIED         \tab Implied                                                                                    \cr
#' 4E            \tab LG_ORDER        \tab Large Order                                                                                \cr
#' 4F            \tab SM_ORDER        \tab Small Order                                                                                \cr
#' 50            \tab MATCH           \tab Match/Cross Trade                                                                          \cr
#' 51            \tab NOMINAL         \tab Nominal                                                                                    \cr
#' 52            \tab OPTION_EX       \tab Option Exercise                                                                            \cr
#' 53            \tab PERCENTAGE      \tab Percentage                                                                                 \cr
#' 54            \tab AUTOQUOTE       \tab Auto Quotes                                                                                \cr
#' 55            \tab INDICATIVE      \tab Indicative                                                                                 \cr
#' 56            \tab TAKE            \tab Take                                                                                       \cr
#' 57            \tab NOMINAL_CABINET \tab Nominal Cabinet                                                                            \cr
#' 58            \tab CHNG_TRANSACTION\tab Changing Transaction                                                                       \cr
#' 59            \tab CHNG_TRANS_CAB  \tab Changing Transaction Cabinet                                                               \cr
#' 5A            \tab FAST            \tab Fast Market (ssfutures)                                                                    \cr
#' 5B            \tab NOMINAL_UPDATE  \tab Nominal Update                                                                             \cr
#' 5C            \tab INACTIVE        \tab Inactive - Nominal - No Trade                                                              \cr
#' 5D            \tab DELTA           \tab Last Trade with Delta Exchange                                                             \cr
#' 5E            \tab ERRATIC         \tab Erratic                                                                                    \cr
#' 5F            \tab RISK_FACTOR     \tab Risk Factor                                                                                \cr
#' 60            \tab OPT_ADDON       \tab Short Option Add-On                                                                        \cr
#' 61            \tab VOLATILITY      \tab Volatility Trade                                                                           \cr
#' 62            \tab SPD_RPT         \tab Spread Reporting                                                                           \cr
#' 63            \tab VOL_ADJ         \tab Volume Adjustment                                                                          \cr
#' 64            \tab BLANK           \tab Blank out associated price                                                                 \cr
#' 65            \tab SOLDLATE        \tab Late report of transaction - in correct sequence                                           \cr
#' 66            \tab BLKT            \tab Block Trade                                                                                \cr
#' 67            \tab EXPH            \tab Exchange Future for Physical                                                               \cr
#' 68            \tab SPECIALIST_A    \tab Ask from specialist Book                                                                   \cr
#' 69            \tab SPECIALIST_B    \tab Bid from specialist Book                                                                   \cr
#' 6A            \tab SPECIALIST_BA   \tab Both Bid and Ask from Specialist Book                                                      \cr
#' 6B            \tab ROTATION        \tab Rotation                                                                                   \cr
#' 6C            \tab HOLIDAY         \tab Holiday                                                                                    \cr
#' 6D            \tab PREOPENING      \tab Pre Opening                                                                                \cr
#' 6E            \tab POST_FULL       \tab Post Full                                                                                  \cr
#' 6F            \tab POST_RESTRICTED \tab Post Restricted                                                                            \cr
#' 70            \tab CLOSING_AUCTION \tab Closing Auction                                                                            \cr
#' 71            \tab BATCH           \tab Batch                                                                                      \cr
#' 72            \tab TRADING         \tab Trading                                                                                    \cr
#' 73            \tab OFFICIAL        \tab Official Bid/Ask price                                                                     \cr
#' 74            \tab UNOFFICIAL      \tab Unofficial Bid/Ask price                                                                   \cr
#' 75            \tab MIDPRICE        \tab Midprice last                                                                              \cr
#' 76            \tab FLOOR           \tab Floor B/A price                                                                            \cr
#' 77            \tab CLOSE           \tab Closing Price                                                                              \cr
#' 78            \tab HIGH            \tab End of Session High Price                                                                  \cr
#' 79            \tab LOW             \tab End of Session Low Price                                                                   \cr
#' 7A            \tab BACKWARDATION   \tab Backwardation - immediate delivery costing more than future delivery                       \cr
#' 7B            \tab CONTANGO        \tab Contango - future delivery costing more than immediate delivery                            \cr
#' 7C            \tab RF_SETTLEMENT   \tab Refined Fuel Spot Settlement                                                               \cr
#' 7D            \tab RF_RESERVED1    \tab Refined Fuel Spot Reserved - 1                                                             \cr
#' 7E            \tab RF_RESERVED2    \tab Refined Fuel Spot Reserved - 2                                                             \cr
#' 7F            \tab RF_RESERVED3    \tab Refined Fuel Spot Reserved - 3                                                             \cr
#' 80            \tab RF_RESERVED4    \tab Refined Fuel Spot Reserved - 4                                                             \cr
#' 81            \tab YIELD           \tab Yield Price                                                                                \cr
#' 82            \tab BASIS_HIGH      \tab Current Basis High Value                                                                   \cr
#' 83            \tab BASIS_LOW       \tab Current Bases Low Value                                                                    \cr
#' 84            \tab UNCLEAR         \tab bid or offer price is unclear                                                              \cr
#' 85            \tab OTC             \tab Over the counter trade                                                                     \cr
#' 86            \tab MS              \tab Trade entered by Market Supervision                                                        \cr
#' 87            \tab ODDLOT          \tab Odd lot trade                                                                              \cr
#' 88            \tab CORRCSLDLAST    \tab Corrected Consolidated last                                                                \cr
#' 89            \tab QUALCONT        \tab Qualified Contingent Trade                                                                 \cr
#' 8A            \tab MC_OPEN         \tab Market Center Opening Trade                                                                \cr
#' 8B            \tab CONFIRMED       \tab Confirmed                                                                                  \cr
#' 8C            \tab OUTAGE          \tab Outage                                                                                     \cr
#' 8D            \tab SPRD_LEG        \tab CME spread leg trade                                                                       \cr
#' 8E            \tab BNDL_SPRD_LEG   \tab Final CME MDP3 trade from Trade Summary message that could not be Un-Bundled               \cr
#' 8F            \tab LATECORR        \tab LSE - Late Correction                                                                      \cr
#' 90            \tab CONTRA          \tab LSE - Previous days contra                                                                 \cr
#' 91            \tab IF_TRANSFER     \tab LSE - Inter-fund transfer                                                                  \cr
#' 92            \tab IF_CROSS        \tab LSE - Inter-fund Cross                                                                     \cr
#' 93            \tab NEG_TRADE       \tab LSE - Negotiated Trade                                                                     \cr
#' 94            \tab OTC_CANC        \tab LSE - OTC Trade Cancellation                                                               \cr
#' 95            \tab OTC_TRADE       \tab LSE - OTC Trade                                                                            \cr
#' 96            \tab SI_LATECORR     \tab LSE - SI Late Correction                                                                   \cr
#' 97            \tab SI_TRADE        \tab LSE - SI Trade                                                                             \cr
#' 98            \tab AUCT_TRADE      \tab LSE - Auctions (bulk;individual)                                                           \cr
#' 99            \tab LATE            \tab LSE - Late trade                                                                           \cr
#' 9A            \tab STRAT           \tab LSE - Strategy vs. Strategy Trade trade                                                    \cr
#' 9B            \tab INDICATIVE_AUCT \tab LSE - Indicative Auction Uncrossing Data
#' }
#' * to retireve above table use \code{QuantTools:::.get_iqfeed_trade_conditions_info()}
#'

#
NULL

iqfeed = R6::R6Class( 'iqfeed', lock_objects = F )
iqfeed$set( 'public', 'initialize', function( host = .settings$iqfeed_host, port = list( stream = 5009, lookup = .settings$iqfeed_port ), timeout = .settings$iqfeed_timeout, verbose = .settings$iqfeed_verbose, stream = FALSE ) {

  self$stream = stream
  self$settings = list( host = host, port = port, timeout = timeout, verbose = verbose, buffer_size = .settings$iqfeed_buffer )
  self$settings$buffer_size_stream = 1000

} )
iqfeed$set( 'public', 'verbose_message', function( text ) {

  text = paste( Sys.time(), substr( text, 1, 100 ), '...' )
  text = gsub( '\n','\\\\n', text )
  text = gsub( '\r','\\\\r', text )

  if( self$settings$verbose ) message( text )

} )
iqfeed$set( 'public', 'read_chain', function( prefix, split, con, n ) {

  text = paste0( prefix, readChar( con, n ) )
  if( self$settings$timeout < 1 ) Sys.sleep( self$settings$timeout )
  last_split = regexpr( paste0( split, '[^', split, ']*$' ), text )

  if( last_split > 0 ) list(
    complete = strtrim( text, last_split ),
    tail = substr( text, last_split + 1, nchar( text ) )
  ) else list(
    complete = '',
    tail = text
  )

} )
iqfeed$set( 'public', 'connect', function() {

  ## connect
  self$connection = lapply( self$settings$port[ c( 'lookup', if( self$stream ) 'stream' ) ], socketConnection,
                            host    = self$settings$host,
                            timeout = self$settings$timeout,
                            open = 'a+b',
                            blocking = TRUE )

  ## set protocol
  protocol = 'S,SET PROTOCOL,5.2\r\n'
  if( self$stream ) writeChar( protocol, self$connection$stream )
  writeChar( protocol, self$connection$lookup )
  if( self$settings$timeout < 1 ) Sys.sleep( self$settings$timeout )
  ## confirm lookup
  confirmation = gsub( 'SET', 'CURRENT', protocol )
  self$verbose_message( readChar( self$connection$lookup, n = nchar( confirmation ) ) )

} )
iqfeed$set( 'public', 'disconnect', function() {

  if( self$stream ) close( self$connection$stream )
  close( self$connection$lookup )

} )
iqfeed$set( 'public', 'subscribe', function( symbol ) {

  if( is.null( self$subscribed ) ) self$subscribed = symbol else self$subscribed[ length( self$subscribed ) + 1 ] =  symbol
  cmd = paste0( 't', symbol, '\r\n' )
  cat( cmd, file = self$connection$stream )

} )
iqfeed$set( 'public', 'unsubscribe', function( symbol ) {

  self$subscribed = self$subscribed[ self$subscribed != symbol ]
  cmd = paste0( 'r', symbol, '\r\n' )
  cat( cmd, file = self$connection$stream )

} )
iqfeed$set( 'public', 'read', function() {

  if( is.null( self$stream ) ) {
    self$stream_messages = vector( 5e07, mode = 'list' )
    self$stream_quotes   = vector( 5e07, mode = 'list' )
    self$stream_hbeats   = vector( 5e07, mode = 'list' )
    self$stream_index = 1
    self$stream_tail = ''
  }
  curr_time = Sys.time() + as.difftime( 1, units = 'hours' )
  attr( curr_time, 'tzone' ) = 'EST'
  stop_message = paste0( 'T,', format( curr_time, '%Y%m%d %H:%M:%S' ) )

  hbeats_names = c( 'T', 'time' )
  quotes_names = c( 'Q','symbol','price','volume','time','trade_market_center','total_volume','bid','bid_volume','ask','ask_volume','open','high','low','close','contents','trade_conditions','tail' )

  message_chunk = list( complete = '', tail = self$stream_tail )

  repeat {

    message_chunk = self$read_chain( message_chunk$tail, split = '\n', con = self$connection$stream, n = self$settings$buffer_size_stream )
    self$stream_tail = message_chunk$tail

    text = message_chunk$complete
    messages = strsplit( text, '\n', fixed = TRUE )[[1]]
    header_tag = 'S,CURRENT UPDATE FIELDNAMES,'
    header = grep( header_tag, messages, fixed = T, value = T )
    quotes = grep( '^Q,', messages, value = T )
    hbeats = grep( '^T,', messages, value = T )

    self$stream_messages[[ self$stream_index ]] = messages
    if( length( quotes ) ) self$stream_quotes[[ self$stream_index ]] = fread( paste( c( quotes, '' ), collapse = '\n' ), header = F, col.names = quotes_names )[,-c( 'Q', 'tail' ) ]
    if( length( hbeats ) ) self$stream_hbeats[[ self$stream_index ]] = fread( paste( c( hbeats, '' ), collapse = '\n' ), header = F, col.names = hbeats_names, sep = ',' )[,-'T' ]
    # broken when 1 line fed to fread

    self$stream_index = self$stream_index + 1

    terminated = grepl( stop_message, message_chunk$complete, fixed = T )
    if( terminated ) break

  }

} )
iqfeed$set( 'public', 'get_trades', function() {

  rbindlist( self$stream_quotes[ 2:self$stream_index - 1 ] )

} )
iqfeed$set( 'public', 'lookup', function( cmd, colClasses = NULL ) {

  writeChar( cmd, self$connection$lookup )

  message_chunks = vector( 5e06, mode = 'list' )
  message_chunk_index = 1

  retry_index = 0
  max_n_retry = 10
  terminator  = '!ENDMSG!,\r\n'
  no_data_tag = '!NO_DATA!'
  invalid_tag = 'Unauthorized user ID.'
  message_chunk = list( complete = '', tail = '' )

  repeat {

    message_chunk = self$read_chain( message_chunk$tail, split = '\n', con = self$connection$lookup, n = self$settings$buffer_size )
    self$verbose_message( message_chunk$complete )
    terminated = grepl( terminator, message_chunk$complete, fixed = T )
    if( terminated ) {

      if( grepl( no_data_tag, message_chunk$complete, fixed = T ) ) {
        message( no_data_tag )
        return( NULL )
      }
      if( grepl( invalid_tag, message_chunk$complete, fixed = T ) ) {
        message( invalid_tag )
        return( NULL )
      }

      message_chunk$complete = strtrim( message_chunk$complete, nchar( message_chunk$complete ) - nchar( terminator ) )

    }
    message_chunk$complete = gsub( ', ', ';', message_chunk$complete, fixed = TRUE )

    if( message_chunk$complete != '' ) {

      message_chunks[[ message_chunk_index ]] = fread( message_chunk$complete, sep = ',', colClasses = colClasses, fill = T )

    } else {

      retry_index = retry_index + 1
      if( retry_index > max_n_retry ) return( message( 'Tried 10 times with no result. Check IQFeed client and try again. NULL returned.' ) )

    }

    if( terminated ) break
    message_chunk_index = message_chunk_index + 1

  }
  x = rbindlist( message_chunks[ 1:message_chunk_index ] )
  x[, -ncol( x ), with = FALSE ]

} )
iqfeed$set( 'public', 'lookup_mult', function( cmd ) {

  #lapply( cmd, writeChar, self$connection$lookup )
  writeChar( paste( cmd, collapse = '' ), self$connection$lookup )

  message_chunks = vector( 5e06, mode = 'list' )
  message_chunk_index = 1

  retry_index = 0
  max_n_retry = 10
  terminator  = '!ENDMSG!,\r\n'

  n_terminator = 0
  n_terminator_max = length( cmd )

  nstr = function( x, pattern ) ( nchar( x ) - nchar( gsub( pattern, '', x, fixed = T ) ) ) / nchar( pattern )

  repeat {

    message_chunk = self$read_chain( message_chunk$tail, split = '\n', con = self$connection$lookup, n = self$settings$buffer_size )
    self$verbose_message( message_chunk$complete )
    n_terminator = n_terminator + nstr( message_chunk$complete, terminator )

    terminated = n_terminator == n_terminator_max
    message_chunk$complete = gsub( ', ', ';', message_chunk$complete, fixed = TRUE )

    if( message_chunk$complete != '' ) message_chunks[[ message_chunk_index ]] = message_chunk$complete

    if( terminated ) break
    message_chunk_index = message_chunk_index + 1

  }

  x = paste( unlist( message_chunks[ 1:message_chunk_index ] ), collapse = '\r\n' )
  x = strsplit( x, split = terminator, fixed = TRUE )[[1]]
  x = lapply( x, gsub, pattern = ',\r', replacement = '', fixed = T )
  x = lapply( x, fread )
  names( x ) = cmd

  return( x )

} )
iqfeed$set( 'public', 'get_markets', function() {

  markets = self$lookup( cmd = 'SLM\r\n' )
  setnames( markets, c( 'market_id', 'short_name', 'long_name', 'group_id', 'group_name' ) )
  markets[]

} )
iqfeed$set( 'public', 'get_trade_conditions', function() {

  codes = self$lookup( cmd = 'STC\r\n' )
  setnames( codes, c( 'condition_code', 'short_name', 'description' ) )
  codes[, condition_code := toupper( as.hexmode( condition_code ) ) ][]

} )
iqfeed$set( 'public', 'get_security_types', function() {

  types = self$lookup( cmd = 'SST\r\n' )
  setnames( types, c( 'type_id', 'short_name', 'long_name' ) )
  types[]

} )
iqfeed$set( 'public', 'search_by_filter', function( search_field = 's', search_string = 'AAPL', filter_type = 't', filter_value = '' ) {

  cmd = paste0( paste( 'SBF', search_field, search_string, filter_type, filter_value, sep = ',' ), '\r\n' )
  search_result = self$lookup( cmd )
  if( is.null( search_result ) ) return()
  setnames( search_result, c( 'symbol', 'market', 'type', 'description' ) )
  search_result

} )
iqfeed$set( 'public', 'get_ticks', function( symbol, n_ticks, n_days, from, to ) {

  cmd = if( !missing( n_ticks ) ) {

    paste0( paste( 'HTX', symbol, max = n_ticks, direction = '1', sep = ',' ), '\r\n' )

  } else if( !missing( n_days ) ) {

    paste0( paste( 'HTD', symbol, n_days, max = '', time_begin = '', time_end = '', direction = '1', sep = ',' ), '\r\n' )

  } else if( missing( from ) & missing( to ) ) stop( 'no arguments set' ) else {

    paste0( paste( 'HTT', symbol, datetime_begin = format( as.POSIXct( from ), '%Y%m%d %H%M%S' ), datetime_end = format( as.POSIXct( to ) + ( nchar( to ) == 10 ) * as.difftime( '24:00:00' ), '%Y%m%d %H%M%S' ), max = '', time_begin = '', time_end = '', direction = '1', sep = ',' ), '\r\n' )

  }

  colClasses = c( 'character', rep( 'numeric', 6 ), rep( 'character', 3 ), 'numeric' )
  ticks = self$lookup( cmd, colClasses )
  if( is.null( ticks ) ) return( NULL )
  setnames( ticks, c( 'time','price','volume','size','bid','ask','tick_id','basis_for_last', 'trade_market_center', 'trade_conditions' ) )
  ticks[, time := fasttime::fastPOSIXct( time, 'UTC' ) ][]

} )
iqfeed$set( 'public', 'get_intraday_candles', function( symbol, interval, n_candles, n_days, from, to, type = 's' ) {

  cmd = if( !missing( n_candles ) ) {

    paste0( paste( 'HIX', symbol, interval, max = n_candles, direction = '1', request_id = '', points_sent = '', type, sep = ',' ), '\r\n' )

  } else if( !missing( n_days ) ) {

    paste0( paste( 'HID', symbol, interval, n_days, max = '', time_begin = '', time_end = '', direction = '1', request_id = '', points_sent = '', type, sep = ',' ), '\r\n' )

  } else if( missing( from ) & missing( to ) ) stop( 'no arguments set' ) else {

    paste0( paste( 'HIT', symbol, interval, datetime_begin = format( as.POSIXct( from ), '%Y%m%d %H%M%S' ), datetime_end = format( as.POSIXct( to ) + ( nchar( to ) == 10 ) * as.difftime( '24:00:00' ), '%Y%m%d %H%M%S' ), max = '', time_begin = '', time_end = '', direction = '1', request_id = '', points_sent = '', type, sep = ',' ), '\r\n' )

  }

  candles = self$lookup( cmd )
  if( is.null( candles ) ) return( NULL )
  setnames( candles, c( 'time', 'high', 'low', 'open', 'close', 'total_volume', 'volume', 'n_trades' ) )
  candles[, ':='( total_volume = NULL, n_trades = NULL ) ]
  setcolorder( candles, c( 'time', 'open', 'high', 'low', 'close', 'volume' ) )
  candles[, time := fasttime::fastPOSIXct( time, 'UTC' ) ][]

} )
iqfeed$set( 'public', 'get_daily_candles', function( symbol, n_days, n_weeks, n_months, from, to ) {

  cmd = if( !missing( n_days ) ) {

    paste0( paste( 'HDX', symbol, max = n_days, direction = '1', request_id = '', points_sent = '', sep = ',' ), '\r\n' )

  } else if( !missing( n_weeks ) ) {

    paste0( paste( 'HWX', symbol, max = n_weeks, direction = '1', request_id = '', points_sent = '', sep = ',' ), '\r\n' )

  } else if( !missing( n_months ) ) {

    paste0( paste( 'HMX', symbol, max = n_months, direction = '1', request_id = '', points_sent = '', sep = ',' ), '\r\n' )

  } else if( missing( from ) & missing( to ) ) stop( 'no arguments set' ) else {

    paste0( paste( 'HDT', symbol, date_begin = format( as.Date( from ), '%Y%m%d' ), date_end = format( as.Date( to ), '%Y%m%d' ), max = '', direction = '1', request_id = '', points_sent = '', sep = ',' ), '\r\n' )

  }

  candles = self$lookup( cmd )
  if( is.null( candles ) ) return( NULL )

  setnames( candles, c( 'date', 'high', 'low', 'open', 'close', 'volume', 'open_interest' ) )

  setcolorder( candles, c( 'date', 'open', 'high', 'low', 'close', 'volume', 'open_interest' ) )
  candles[, date := as.Date( date ) ][]

} )

.get_iqfeed_daily_candles = function( symbol, from, to ) {

  self = iqfeed$new()
  self$connect()
  x = self$get_daily_candles( symbol = symbol, from = from, to = to )
  self$disconnect()
  return( x )

}
.get_iqfeed_recent_daily_candles = function( symbol, days = 10 ) {

  self = iqfeed$new()
  self$connect()
  x = self$get_daily_candles( symbol = symbol, n_days = days )
  self$disconnect()
  return( x )

}
.get_iqfeed_candles = function( symbol, from, to, interval = 3600 ) {
  self = iqfeed$new()
  self$connect()
  x = self$get_intraday_candles( symbol = symbol, interval = interval, from = from, to = to )
  self$disconnect()
  return( x )
}
.get_iqfeed_ticks = function( symbol, from, to = from ) {
  self = iqfeed$new()
  self$connect()
  x = self$get_ticks( symbol = symbol, from = from, to = to )
  self$disconnect()
  return( x )
}
.get_iqfeed = function( cmd ) {
  self = iqfeed$new()
  self$connect()
  x = self$lookup( cmd )
  self$disconnect()
  return( x )
}
.get_iqfeed_markets_info = function( ){
  self = iqfeed$new()
  self$connect()
  x = self$get_markets()
  self$disconnect()
  return( x )
}
.get_iqfeed_security_types_info = function( ){
  self = iqfeed$new()
  self$connect()
  x = self$get_security_types()
  self$disconnect()
  return( x )
}
.get_iqfeed_symbol_info = function( symbol, type_ids ){

  cmd = paste0( 'SBF,s,', symbol, ',t,', paste( type_ids, collapse = ' ' ), '\r\n' )
  info = .get_iqfeed( cmd )
  if( is.null( info ) ) return()
  setnames( info, c( 'symbol', 'market', 'type', 'description' ) )
  .symbol = symbol
  info = info[ symbol == .symbol ]
  if( nrow( info ) == 0 ) return()
  info[]

}
.get_iqfeed_trade_conditions_info = function( ){
  self = iqfeed$new()
  self$connect()
  x = self$get_trade_conditions()
  self$disconnect()
  return( x )
}

