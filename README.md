# SwingKit
SwingKit is a custom indicator designed to outline the swings of the market and provide relevant frequency distribution statistics to find and locate trading oppurtunities that produce a positive expected value.

## Swing Construction
Below are instructions on how the swings of the market are constructed within the indicator.

### 1. Initial Data Points
Use the following moving standard indicator as a guide. I recommend to use the in built moving average 1st, then create the indicator from step 2 onwards to ensure the rest of the logic is correct.

a-LWMA High line = High + Linear Weighted Moving Average + Period 8 + Shift 1

b-LWMA Low line = Low + Linear Weighted Moving Average + Period 8 + Shift 1
 
### 2. Swing Line Logic
a-Downswing run = candle closes below LWMA High line
Ensure swing end point is always the lowest extreme before the next new upswing turn happens.
Mark and keep these LWMA High line data points, hide it later.

b-Downswing turn into upswing = candle closes above LWMA High line
Start of a new swing going up, tracking the highest extreme after it.
Mark and keep this turn point data point.

c-Upswing run = candle closes above LWMA Low line
Ensure swing end point is always the highest extreme before the next new downswing turn happens.
Mark and keep these LWMA Low line data points.

d-Upswing turn into downswing = candle closes below LWMA Low line
Start of a new swing going down, tracking the lowest extreme after it.
Mark and keep this turn point data point.

### 3. Swing Classification
There are 3 types of swings in total
1. Retrace Swings: Swings retrace does not exceed the previous swing.
2. Trend Swings: Swings retrace does exceed the previous swing, and a candle closes beyond this point.
3. Reject Swings: Swings retrace does exceed the previous swing and a candle does not close beyond this point.

The reject swings are few and far between so we can either combine them into our reject swings or our trend swings. I personally think it makes more sense to combine them into the trend swings because the previous swing is exceed and individual candle closing times are "sythentic".
