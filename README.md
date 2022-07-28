# Euclid's Elements with Julia

Coding out Euclid's Elements in Julia :D

This is a pretty simple package just trying to code out the various propositions worked out by Euclid, with Julia. This uses Makie to graph the problems Euclid worked through.

Euclid's Elements are largely based on compass and straight edge construction, requiring some translation to cartesian system, with trig and linear algebra to do some tricks. Some stuff Euclid does is thus totally redundant, but it is rather useful to put it in code and see what Euclid was up to!


This repository is broken up into folders based on the books of Euclid's Elements and some supplementary material.

Each proposition is primarily done with one, very simple unit version to figure out Euclid's arguments. It is then applied with various rotations, etc. if not already covered, and from this, a function is pulled out. Not all propositions will have a unique function pulled out to demonstrate the argument--mostly those ending with QEF--that is, where the proposition is to construct something. All propositions are finished with an attempt at creating an animation that either shows the proof or shows a rotating, dynamic version of the construction.

`EuclidElements.jl` is a shorthand way to include a bunch of utility stuffs
`EuclidMath-*.jl` are individual files in which specific mathematical functions derived from Euclid's Elements are defined
`EuclidGraph-*.jl` are individual files for code used in graphing Euclid's Elements, including and especially animations
