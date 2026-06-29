# MAC Array Control Unit — Neural Network Accelerator (Basys3 FPGA)

> Day 4 of building a Neural Network Accelerator on the Basys3 FPGA using VHDL on Vivado.

---

## Overview

The MAC Array Control Unit is a Finite State Machine (FSM) that orchestrates all memory accesses and computation scheduling for a MAC (Multiply-Accumulate) array. It drives three counters:

- **Distribution Counter** — generates parameter destination addresses (Parameter Buffers) and activation source addresses (Activations Buffer)
- **Parameters Counter** — generates parameter source addresses (Parameter BRAM)
- **Activations Counter** — generates activation destination addresses (Activations BRAM)

---

## FSM States

### `IDLE`
Held here on reset (`START = 0`). Transitions to `FETCH` on a `START = 1` pulse.

### `FETCH`
Fetches parameters from Parameter BRAM into the Parameter Buffer. Distribution Counter and Parameters Counter are initiated. Transitions to `COMPUTE` once the Parameter Buffer is full.

### `COMPUTE`
Generates a compute enable pulse for the MAC units. Transitions back to `FETCH` if there are remaining parameters for the current layer, or to `STORE` if all parameters have been fetched.

### `STORE`
Transfers activations from the Activations Buffer to Activations BRAM. Transitions to `CLEAR` once the Activations Buffer is empty.

### `CLEAR`
Clears the accumulators of all MAC units. Transitions to `IDLE` if the current layer is the output layer, or back to `FETCH` for the next layer otherwise.

---

## Simulation & Verification

Behavioural simulation conducted for a 3-layer network with topology **(4 : 2 : 1)** neurons. Observed results matched expected results.

---

## Tools

| Tool | Details |
|---|---|
| Language | VHDL |
| IDE | Vivado |
| Target board | Basys3 FPGA |

---
