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
1. Retrace Swings (R): Swings retrace does not exceed the previous swing.
2. Trend Swings (T): Swings retrace does exceed the previous swing, and a candle closes beyond this point.
3. Reject Swings (J): Swings retrace does exceed the previous swing and a candle does not close beyond this point.

The reject swings are few and far between so we can either combine them into our reject swings or our trend swings. I personally think it makes more sense to combine them into the trend swings because the previous swing is exceed and individual candle closing times are "sythentic".

EURUSD 4HR Swing to Swing Distributions Counting Js at Ts:

![alt text](https://github.com/ipbyrne/SwingKit/blob/master/JasT.PNG?raw=true "J Swings as T Swings")

EURUSD 4HR Swing to Swing Distributions Counting Js at Rs:

![alt text](https://github.com/ipbyrne/SwingKit/blob/master/JasR.PNG?raw=true "J Swings as R Swings")

You can see how the probabilities change depending on how you classify the Reject (J) Swings.

## Swing Data Verification
Now that we have our swing distribution data, we need to verify the accuracy of this data via hypothesis testing.

We want to make sure the difference we see between which swings lead to what, is not due to random chance. A hypothesis test can tell us if the difference we see in the percentages is statistically significant, and whether the swing type variables and prefances are independent or not.

To evaluate the statistical significance of our results, we will use a hypothesis test called the chi-square test. This test compares the counts observed in the data we’ve collected to the counts we would expect if there is no relationship between the variables.

### Chi-Squared Hypothesis Testing
The first thing we must do is establish our Null Hypothesis.

**Null Hypohtesis: The relationship between swings and which swings lead to which, are totally independent.**

Now that we have esbalished our null hypothesis, we can perform our Chi-Squared test to determine our p-value. If we receive a p-value of .05 or less, we can reject the null hypothesis with 95% confidence. 

In other words, there is a stastiscal signifcance between which swings lead to which.

EURUSD 4HR Swing to Swing Distributions Counting Js at Ts Chi-Squared Test:

![alt text](https://github.com/ipbyrne/SwingKit/blob/master/JasT-Chi-Squared.PNG?raw=true "J Swings as T Swings")

EURUSD 4HR Swing to Swing Distributions Counting Js at Rs Chi-Squared Test:

![alt text](https://github.com/ipbyrne/SwingKit/blob/master/JasR-Chi-Squared.PNG?raw=true "J Swings as R Swings")

### Interpreting The Results
Depending on how you classify the Reject Swings (J), the results of our Chi-Squared Test vary quite drastically.

**In both cases, the resulting swings after a Trend Swing (T), are considered to be not random at all.**

**If you classify the Reject Swings (J) as Trend Swings (T), the resulting swings after a Retrace Swing (R), are considered to be not random at all.**

**If you classify the Reject Swings (J) as Retrace Swings (R), the resulting swings after a Retrace Swing (R), are considered to be random.**

As previously stated, I personally think it makes more sense to clasiffy the Reject Swings (J) as Trend Swings (T) because the new swing has retraced past the initial length of the previous swing, which will create a new high (or low), which by definition, is a continuated of a trend, or the start of a new one.

When accepting the premise that Reject Swings (J) should be classified as Trend Swings (T), we are able to reject the null hypothesis with more than 99% confidence.

**As a result, the relationship between swings and which swings lead to which, are NOT independent or random.**

## How to Trade Swings
Think of our statistically verified swing data as a probability map that tells us where the market is most likely to go next at any given time. We can use this "map" to find zones in the market for each swing that will produce a positive expected value if we are able to enter within that zone while the current swing is still open.

### Trade Example 1

![alt text](https://github.com/ipbyrne/SwingKit/blob/master/TradeExample1.PNG?raw=true "Trade Example 1")

Below are the frequency distributions for the following swings on the AUDUSD currency pair using a 4hr chart.
- DR to UR: 32%
- UR to DT: 62%

The circled candle shows when the leg marked with a 1 was confirmed as a downward retrace swing. Once confirmed, there is a 32% chance the next swing will be an upward retrace swing. If the market does go on the form an upward retrace swing, there is a 62% chance the following swing will be a downward trend swing.

Once the swing marked 1 is confirmed, we are looking to get short at any price above the break even entry line placed at the 32% retrace level. If get an entry below that level with the stop at the top of the leg marked 1 and take profit at the bottom, before leg 2 is confirmed, there is 32% chance that stop will not be hit by the time leg 2 completes. If/when this occurs, there is now a 62% chance leg 3 will continue on reach the take profit.

As long as you entered above the 32% level before leg 2 closes or above the 62% level before leg 3 closes, that trade will have produced a positive expected value.

### Trade Example 2

![alt text](https://github.com/ipbyrne/SwingKit/blob/master/TradeExample2.PNG?raw=true "Trade Example 2")

Below are the frequency distributions for the following swings on the GBPAUD currency pair using a 4hr chart.
- UT to DR: 70%
- DR to UT: 66%

The circled candle shows when the leg marked with a 1 was confirmed as an upward trend swing. Once confirmed, there is a 70% chance the next swing will be an downward retrace swing. If the market does go on the form an downward retrace swing, there is a 66% chance the following swing will be an upward trend swing.

Once the swing marked 1 is confirmed, we are looking to get long at any price below the break even entry line placed at the 66% retrace level. If get an entry below that level with the stop at the bottom of the leg marked 1 and take profit at the top, before leg 2 is confirmed, there is 70% chance that stop will not be hit by the time leg 2 completes. If/when this occurs, there is now a 66% chance leg 3 will continue on reach the take profit.

As long as you entered below the 66% level before leg 2 or 3 closes, that trade will have produced a positive expected value. If you were to enter below to the 70% but above the 66% level before leg 2 closes, the trade would have produced a negative expected value even though the pattern played out as predicted.

## Expected Performance
When trading, the overall expected performance of your trades is the average surplus between your entry and the break even entry level for each setup, minus the spread risk in relation to the entire distance between your stop and target. For example if this distance is 100 pips and the spread is 2 pips, the spread risk is 2%. This means if your break even entry is 66%, you actually need to enter below 64% (if going long) in order to break even.

You need to choose a multiple of this spread risk that will serve as your minimum entry level which will create a fixed edge. This way you can calculate the expected performance of your system overtime.

The following simulates having a x% edge with a $10,000 account risking $200 per trade over 500 trades.

### 1% Edge

![alt text](https://github.com/ipbyrne/SwingKit/blob/master/1PE.PNG?raw=true "1% Edge")

### 2% Edge

![alt text](https://github.com/ipbyrne/SwingKit/blob/master/2PE.PNG?raw=true "2% Edge")

### 3% Edge

![alt text](https://github.com/ipbyrne/SwingKit/blob/master/3PE.PNG?raw=true "3% Edge")

### 4% Edge

![alt text](https://github.com/ipbyrne/SwingKit/blob/master/4PE.PNG?raw=true "4% Edge")

### Conclusion
We can see that anything less than a 1% edge will produce very rocky results, althought they will be positive over time, the equity swings will be very wild. Starting with a 2% edge we can see our equity curve will normalize and form a very clear trend. From the on, the positive trend increases as our edge does, as one would expect.

As a result, one can conclude that having a minimum fixed 2% edge above the spread risk will produce a steady equity curve that will be easy to manage. Anything less will be psychologically hard to manage as the swings will be very large.
