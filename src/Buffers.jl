module Buffers

using MacroTools: @forward
using ZygoteRules
using ZygoteRules: AContext

export Buffer, bufferfrom

include("lib.jl")
include("buffer.jl")

end # module
