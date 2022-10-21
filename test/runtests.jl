using WordErrorRate
using Test
using Printf

include("test.jl")

function compare_to_nist()
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
end

compare_to_nist()
