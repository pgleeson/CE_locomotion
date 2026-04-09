# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Evolutionary optimization of a neuromechanical model of *C. elegans* locomotion. A genetic algorithm evolves 17 parameters governing a neural circuit (ventral nerve cord) that drives a mechanical body model to produce forward and backward locomotion via command neuron modulation.

## Build & Run

```bash
make            # Build with g++ -O3 -flto -pthread
./main          # Run evolution (optional integer seed argument)
./main 42       # Run with specific random seed
```

Output files: `fitness.dat` (per-generation fitness), `best.gen.dat` (best genotype), `body.dat`/`curv.dat`/`act.dat` (simulation traces), `phenotype.dat` (decoded neural parameters).

Visualization: `python viz.py` (fitness curves), `python load_data.py` (neural/muscle activity).

## Architecture

The `Worm` class integrates four subsystems each simulation step:

1. **WormBody** — 50-segment mechanical body using Boyle-Berri-Cohen physics (semi-implicit backward Euler DAE). Dorsal/ventral segment pairs with drag forces.
2. **NervousSystem** — CTRNN with 60 neurons (10 repeating units × 6 motoneuron types: DA, DB, DD, VD, VA, VB). Chemical synapses (sparse) and electrical gap junctions.
3. **Muscles** — 24 dorsal/ventral muscle pairs with first-order dynamics (τ=0.1s).
4. **StretchReceptor** — 10 proprioceptive units feeding body curvature back to A-class and B-class motoneurons.

Neuromuscular junctions (NMJ weights) connect motoneuron outputs to muscles. Command interneurons (AVA/AVB) provide top-down drive for forward/backward switching.

**Simulation flow per step:** Body physics → Stretch receptors read curvature → Neural circuit integrates SR + command input → Motoneurons drive muscles → Muscle forces applied to body segments.

**TSearch** runs the evolutionary algorithm: rank-based selection, crossover, mutation over a population (default 96 individuals, multithreaded with 16 threads). The 17-parameter genotype encodes: 2 SR gains, 3 biases, 3 self-connections, 4 intra-unit chemical synapses, 2 inter-unit gap junctions, 3 NMJ weights (excitatory A, excitatory B, inhibitory).

**Fitness function** (`main.cpp`): Simulates 24s (5ms timestep, 8s transient discarded), rewards distance traveled in the correct direction, penalizes wrong-direction movement and incorrect body orientation.

## Key Constants

Defined in `Worm.h`: `N_muscles=24`, `N_units=10`, `N_neuronsperunit=6`, `N_stretchrec=10`, `T_muscle=0.1`.
Defined in `WormBody.h`: `N_segments=50`, `N_rods=51`.

## Preprocessor Flags

Stretch receptor transduction mode is controlled by `#define` flags in `Worm.h`:
- `SR_TRANS_STRETCH` / `SR_TRANS_CONTRACT` / `SR_TRANS_ABS` — select which component of segment deformation is used (default: linear, both stretch and contraction)
- `SR_TRANS_NEG` — invert the sign of SR input

## No Test Suite

There is no formal test infrastructure. Validation is done via evolutionary fitness and post-run visualization.
