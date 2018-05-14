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

In both cases, the resulting swings after a Trend Swing (T), are considered to be not random at all.

If you classify the Reject Swings (J) as Trend Swings (T), the resulting swings after a Retrace Swing (R), are considered to be not random at all.

If you classify the Reject Swings (J) as Retrace Swings (R), the resulting swings after a Retrace Swing (R), are considered to be random.
