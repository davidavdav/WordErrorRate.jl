# WordErrorRate.jl
Compute the word error rate for Automatic Speech Recognition

# Synopsys

using WordErrorRate

ref = ["This", "is", "a", "test"]
hyp = split("This is another")

## align word strings prepare data structure
w = WER(ref, hyp)
## summary
w
## alignmets, referring to indices in ref and hyp
align(w)
## print alignments in a format very similar to NIST sclite:
pralign(w)
str = pralign(String, w)
