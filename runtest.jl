#!/usr/bin/env julia
include("src/WordErrorRate.jl")
using WordErrorRate

cd("test")

include("test/runtests.jl")
