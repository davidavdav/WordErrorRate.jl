using DataStructures

randint(μ, σ) = max(σ, round(Int, randn()σ + μ))

"""
Generate testdata that NIST sclite can read.  Run sclite like:
```
sclite -r ref.txt -h hyp.txt -i rm -o pralign
```
"""
function gentestdata(N::Integer; nw=100, nsub=10, nins=10, ndel=10, V=25, σ=10)
	srand(N)
	reffd = open("test/ref.txt", "w")
	hypfd = open("test/hyp.txt", "w")
	res = DefaultOrderedDict{AbstractString, Vector}(Vector)
	for i in 1:N
		ref = rand(1:V, randint(nw, σ))
		hyp = ref[:]
		for j in 1:randint(nsub, σ)
			hyp[rand(1:length(hyp))] = rand(1:V)
		end
		for j in 1:randint(nins, σ)
			insert!(hyp, rand(1:length(hyp)), rand(1:V))
		end
		for j in 1:randint(ndel, σ)
			deleteat!(hyp, rand(1:length(hyp)))
		end
		id = "a-$i"
		println(reffd, join([string(x) for x in ref], " "), " ($id)")
		println(hypfd, join([string(x) for x in hyp], " "), " ($id)")
		push!(res[id], [string(x) for x in ref])
		push!(res[id], [string(x) for x in hyp])
	end
	close(reffd)
	close(hypfd)
	return res
end

function readtestdata()
	res = DefaultOrderedDict{AbstractString, Vector}(Vector)
	for file in ["ref.txt", "hyp.txt"]
		open(file) do fd
			for line in eachline(fd)
				words = line |> chomp |> split
				id = strip(pop!(words), ['(', ')'])
				push!(res[id], words)
			end
		end
	end
	return res
end

function readsclitepralign(file="hyp.txt.pra")
	res = OrderedDict()
	open(file) do fd
		while !eof(fd)
			m = match(r"id: \(([^()]+)\)", readline(fd))
			if m != nothing
				id = m[1]
				res[id] = join([readline(fd) for i in 1:4], "\n")
			end
		end
	end
	return res
end
