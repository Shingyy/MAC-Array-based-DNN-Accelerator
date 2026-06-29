# MAC Array

## Overview

The MAC array consists of Serial MAC units running computations concurrently. Each Serial MAC unit is optimized to only use 1 DSP for resource utilization.

## Serial MAC Unit

A MAC (Multiply-Accumulate) unit consists of a multiplier, adder, and accumulator register. It does the basic computation every clock cycle:

```
ACC <= ACC + A•B
```

, which makes it useful for dot products in AI Acceleration to perform the fundamental operation:

```
y = w•x + b
```

where w is the weight vector, x is the input vector and b is the bias.

## Serial MAC Unit timing diagram

![Serial MAC Unit Timing Diagram](docs/timing.png)

## Fixed-Point Arithmetic

I used the Q4.4 fixed point arithmetic ( MSB for the sign, next 3 bits for the integer part, last 4 bits for the fraction part) to balance precision and resource utilization.

## Bias Handling

Instead of having a separate bias input ,each MAC unit recognizes the first parameter as the bias and loads it into the accumulator, the subsequent parameters are recognized as weights.

## Requantization

Since the accumulator of each MAC unit outputs a Q8.8 value , the Requantization block converts it back to Q4.4 such that the activations of a hidden layer can be fed into the subsequent layer. This is done by right shifting 4 bits of the Q8.8 value and clamping is also carried out for values outside the Q4.4 range( -8 to 7.9375).

## Overflow Mitigation

However this also introduces a potential overflow problem as some accumulations might fall out of the Q4.4 range. In order to mitigate this , I intend to ensure that the parameters will fall between -1 and 1 whilst the input features will be standardized to fall between 0 and 1 during model training.

## Simulation

I ran behavioral simulations for a 4 MAC Array (K= 2) before and after quantization with the same set of parameters and input features in hexadecimal using Vivado and the results matched the expected outcome. 
