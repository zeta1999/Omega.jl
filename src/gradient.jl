import ForwardDiff
using Flux
using ZenUtils

"Gradient ∇Y()"
function gradient(Y::RandVar{Bool}, ω::Omega, vals = linearize(ω))
  Y(ω)
  #@show Y(ω), ω, vals
  unpackcall(xs) = Y(unlinearize(xs, ω)).epsilon
  ForwardDiff.gradient(unpackcall, vals)
  #@show ReverseDiff.gradient(unpackcall, vals)
end

function gradient(Y::RandVar{Bool}, sω::SimpleOmega{I, V}, vals) where {I, V <: AbstractArray}
  sωtracked = SimpleOmega(Dict(i => param(v) for (i, v) in sω.vals))
  @grab vals
  @show l = epsilon(Y(sωtracked))
  @grab sωtracked
  @grab Y
  @grab l
  # @assert false
  @assert !(isnan(l))
  Flux.back!(l)
  totalgrad = 0.0
  @grab sωtracked
  for v in values(sωtracked.vals)
    @assert !(any(isnan(v)))

    @assert !(any(isnan(v.grad)))
    totalgrad += mean(v.grad)
  end
  @show totalgrad
  sω_ = SimpleOmega(Dict(i => v.data for (i, v) in sωtracked.vals))
  linearize(sω_)
end