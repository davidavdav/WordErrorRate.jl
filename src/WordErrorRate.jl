module WordErrorRate

using Printf: @sprintf

export WER, wer, align, pralign

"""
    WER

a type to hold data to compute the Word Error Rate, an error metric for Automatic Speech Recognition. 
"""
struct WER
    ref::Vector
    hyp::Vector
    nsub::Int
    nins::Int
    ndel::Int
    refeval::Vector{UInt8}
    hypeval::Vector{UInt8}
end

const CORRECT, SUBSTITUTION, INSERTION, DELETION = 0:3

"""
    WER(ref::Vector, hyp::Vector; subcost=4, inscost=3, delcost=3)

Compute the Word Error Rate similar to the NIST sclite package. 

`ref` is a vector of objects known as the reference: ideally, the hypothesis `hyp` that 
is the result of Automatic Speech Recognition should be the same vector of objects.  Every
object that is different, after alignment, counts as an error, and the word error rate 
is the fractions of errors relative to the number of objects in the reference. 

The alignment procedure works by finding the same objects in `ref` and `hyp`, in similar positions, 
where some allowance is made for misaligned object.  An object missing from the `hyp` is called a "detetion", 
an object not aligned to anything in the `ref` is called an "insertion", and when objects are different after 
alignment, this error is evaluated as a "substitution". 
"""
function WER(ref::Vector, hyp::Vector; subcost=4, inscost=3, delcost=3)
    nrow = length(ref) + 1
    ncol = length(hyp) + 1
    ## initialization
    cost = zeros(UInt16, nrow, ncol)
    decision = zeros(UInt8, nrow, ncol)
    for i in 2:nrow
        cost[i, 1] = (i-1) * delcost
        decision[i, 1] = DELETION
    end
    for j in 2:ncol
        cost[1, j] = (j-1) * inscost
        decision[1, j] = INSERTION
    end
    ## computation
    for i in 2:nrow
        for j in 2:ncol
            if ref[i-1] == hyp[j-1]
                cost[i, j] = cost[i-1, j-1]
                decision[i, j] = CORRECT
            else
                sid = [cost[i-1, j-1] + subcost, cost[i, j-1] + inscost, cost[i-1, j] + delcost]
                mini = argmin(sid)
                cost[i, j] = sid[mini]
                decision[i, j] = mini
            end
        end
    end
    ## backtrack
    refeval = UInt8[]
    hypeval = UInt8[]
    i, j = nrow, ncol
    nsub = nins = ndel = 0
    while (i > 1) || (j > 1)
        dec = decision[i, j]
        if dec < 2
            nsub += dec
            i -= 1
            j -= 1
            pushfirst!(refeval, dec)
            pushfirst!(hypeval, dec)
        elseif dec == INSERTION ## ins
            j -= 1
            pushfirst!(hypeval, dec)
            nins += 1
        else
            i -= 1
            pushfirst!(refeval, dec)
            ndel += 1
        end
    end

    return WER(ref, hyp, nsub, nins, ndel, refeval, hypeval)
end

"""
    wer(::WER)

Return the word error rate as computer by a `WER` object. 
"""
wer(w::WER) = (w.nsub + w.nins + w.ndel) / length(w.ref)
wer(ref::Array, hyp::Array; kwargs...) = wer(WER(ref, hyp; kwargs...))

correct(w::WER) = length(w.ref) - w.nsub - w.ndel

"""
    align(::WER)

Compute the indices `refali`, `hypali` and evaluations `evalali` from a 
WER object.  The indices refer to the original vectors `ref` and `hyp`
used to compute the WER.  

The evaluations are in terms of the constants 
`CORRECT, SUBSTITUTION, INSERTION, DELETION = 0:3`
"""
function align(w::WER)
    refali = Int[]
    hypali = Int[]
    evalali = Int8[]
    ri = hi = 1
    while ri ≤ length(w.refeval) || hi ≤ length(w.hypeval)
        if ri ≤ length(w.refeval) && w.refeval[ri] == DELETION
            push!(hypali, 0)
            push!(refali, ri)
            push!(evalali, DELETION)
            ri += 1
        elseif hi ≤ length(w.hypeval) && w.hypeval[hi] == INSERTION
            push!(refali, 0)
            push!(hypali, hi)
            push!(evalali, INSERTION)
            hi += 1
        else
            push!(refali, ri)
            push!(hypali, hi)
            push!(evalali, w.refeval[ri])
            ri += 1
            hi += 1
        end
    end
    return refali, hypali, evalali
end

"""
    pralign(::IO, ::WER; ins="*", del="*")

print alignment in a similar was as sclite does. 
"""
function pralign(io::IO, w::WER; ins="*", del="*")
    println(io, "Scores: (#C #S #D #I) ", correct(w), " ", w.nsub, " ", w.ndel, " ", w.nins)
    refali, hypali, evalali = align(w)
    prref = [i > 0 ? w.ref[i] : del^length(string(w.hyp[j])) for (i, j) in zip(refali, hypali)]
    prhyp = [j > 0 ? w.hyp[j] : ins^length(string(w.ref[i])) for (i, j) in zip(refali, hypali)]
    preval = [" SID"[i+1] for i in evalali]
    lengths = [maximum(length(string(s)) for s in x) for x in zip(prref, prhyp, preval)]
    for (name, a) in zip(("REF: ", "HYP: ", "Eval:"), (prref, prhyp, preval))
        print(io, name, " ")
        for (w, l) in zip(a, lengths)
            s = string(w)
            print(io, s, " "^(l+1-length(s)))
        end
        println(io)
    end
end

pralign(w::WER; kwargs...) = pralign(stdout, w; kwargs...)
function pralign(::Type{String}, w::WER; kwargs...)
    io = IOBuffer()
    pralign(io, w; kwargs...)
    return String(take!(io))
end

"""
    show(::io, ::WER)

Consicely show the information from the WER object in terms of the word error rate, and numbers of subtitutions, 
insertions and deletions
"""
Base.show(io::IO, w::WER) = print(io, @sprintf("Word Error Rate: %4.2f%%, Ns, Ni, Nd = (%d, %d, %d)", 100wer(w), w.nsub, w.nins, w.ndel))

end
