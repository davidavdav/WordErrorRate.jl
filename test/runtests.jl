using WordErrorRate
using Base.Test

include("test.jl")

x = readtestdata()
y = readsclitepralign()
ncorrect = 0
for (key, val) in y
	ref, hyp = x[key]
	w = WER(ref, hyp)
	alignment = chomp(pralign(String, w))
	ncorrect += alignment == val
end
println(@sprintf("Ran tests: %d/%d = %4.1f%% correct", ncorrect, length(y), 100ncorrect/length(y)))
@test ncorrect == length(y)
