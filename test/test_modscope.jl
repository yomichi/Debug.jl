
include(find_in_path("Debug.jl"))

module TestModScope
using Base, Debug
export trap

trap(node::BPNode, scope::Scope) = (global firstline = node.loc.line)
function trap(node::Node, scope::Scope) 
    global firstline
    line = node.loc.line - firstline + 1

    if (line == 3); debug_eval(scope, :(x = 5)) end
    if (line == 4)
        debug_eval(scope, :(let; global y = 7; end))
        debug_eval(scope, :(z = 9))
    end
end

module Mod
using Base, Debug, TestModScope
@instrument trap begin
    @bp             # 1
    x, y, z = 1, 2, 3
    let             # 3
        local z = 1 # 4
    end
    @assert (x, y, z) == (5, 7, 3)
end
end # module Mod

end