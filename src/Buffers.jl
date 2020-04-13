module Buffers

using MacroTools: @forward
using ZygoteRules
using ZygoteRules: AContext

import ZygoteRules: _pullback

export Buffer

include("lib.jl")
include("buffer.jl")

end # module
