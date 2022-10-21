# WordErrorRate.jl
Compute the word error rate for Automatic Speech Recognition, and represent the alignment information in various ways. 

# Synopsys

```julia
julia> using WordErrorRate

julia> ref = ["This", "is", "a", "test"]
4-element Vector{String}:
 "This"
 "is"
 "a"
 "test"

julia> hyp = split("This is another")
3-element Vector{SubString{String}}:
 "This"
 "is"
 "another"

julia> w = WER(ref, hyp)
Word Error Rate: 50.00%, Ns, Ni, Nd = (1, 0, 1)

julia> align(w)
([1, 2, 3, 4], [1, 2, 0, 3], Int8[0, 0, 3, 1])

julia> pralign(w)
Scores: (#C #S #D #I) 2 1 1 0
REF:  This is a test    
HYP:  This is * another 
Eval:         D S       

julia> str = pralign(String, w)
"Scores: (#C #S #D #I) 2 1 1 0\nREF:  This is a test    \nHYP:  This is * another \nEval:         D S       \n"
```

# Install

```julia
Pkg] add https://github.com/davidavdav/WordErrorRate.jl
```

