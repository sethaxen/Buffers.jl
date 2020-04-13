module Buffers

using MacroTools: @forward
using ZygoteRules
using ZygoteRules: AContext

import ZygoteRules: _pullback

export Buffer, bufferfrom

include("lib.jl")
include("buffer.jl")

end # module
