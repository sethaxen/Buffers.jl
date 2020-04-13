# copied from https://github.com/FluxML/Zygote.jl/blob/master/src/lib/lib.jl

cache(cx::AContext) = cx.cache === nothing ? (cx.cache = IdDict()) : cx.cache

function grad_mut(cx::AContext, x)
  ch = cache(cx)
  if haskey(ch, x)
    ch[x]
  else
    ch[x] = grad_mut(x)
  end
end

accum(x, y) =
  x === nothing ? y :
  y === nothing ? x :
  x + y
accum(x::AbstractArray, y::AbstractArray) = accum.(x, y)
