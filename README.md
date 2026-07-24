## FPGA Memory Subsystem: RAM, FIFO, and Delay Buffer

A SystemVerilog RTL project comparing three different ways to implement
delay and storage on an FPGA — flip-flop chains, LUT-based shift registers,
and block RAM — culminating in a RAM-backed FIFO with a ready/valid
handshake interface.

**Stack:** SystemVerilog · Verilator · Icarus Verilog · Yosys · Python/Pytest

### Overview

Implements the same underlying problem — delaying or buffering a stream of
data — three separate ways using different FPGA resources, then compares
their tradeoffs in resource usage, latency, and scalability. A parameterized
FIFO built on top of a custom synchronous RAM module ties the memory work
together into a reusable, verified storage component.

### Highlights

- **Three delay buffer architectures, one problem** — register-based,
  SRL-based, and RAM-based delay buffers all solve the same delay problem,
  making the resource/latency/scalability tradeoffs between FPGA primitives
  directly comparable rather than theoretical
- **Custom synchronous RAM module** — a parameterized single-read,
  single-write RAM with configurable data width and depth, used as the
  storage backbone for both the RAM-based delay buffer and the FIFO
- **RAM-backed FIFO with ready/valid handshaking** — a parameterized FIFO
  built on top of the RAM module, using circular read/write pointers and
  full/empty detection, exposed through a standard ready/valid streaming
  interface
- **Simulation-based verification** — every module is verified with a
  Python/Pytest-driven RTL simulation flow covering timing correctness,
  reset behavior, memory read/write correctness, FIFO ordering, and
  full/empty edge cases across multiple parameter configurations

### How it works

The register-based delay buffer is the simplest of the three: each stage of
delay is a flip-flop, so the buffer is just a chain of registers passing
data forward one clock at a time. It's fast and easy to reason about, but
the flip-flop count grows linearly with delay depth, making it impractical
for long delays.

The SRL-based buffer solves that scaling problem by using the FPGA's
shift-register LUT primitives instead of individual flip-flops, packing
much deeper delay chains into far fewer logic resources — at the cost of
being less flexible than a full RAM for very large or dynamically
addressed delays.

The RAM-based buffer goes further still, storing delayed values in
synchronous block RAM and using address counters to track read and write
positions. This scales efficiently to large delay depths with minimal
resource growth, at the cost of needing extra control logic to manage the
read/write addressing.

That same RAM module is reused as the backing store for the FIFO. The FIFO
wraps it with circular read and write pointers, full/empty detection logic,
and a ready/valid handshake on both the input and output sides — turning
raw RAM access into a standard, composable streaming interface that could
be dropped into a larger data pipeline.

Every module is exercised through a Python/Pytest-based simulation flow
(Verilator/Icarus Verilog for simulation, Yosys for synthesis-adjacent
checks), covering correct timing, reset behavior, memory correctness, FIFO
ordering, and edge conditions like full and empty states across several
parameter configurations.
