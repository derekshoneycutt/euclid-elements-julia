
""" Representation of an animation for comparing 2 lines """
struct EuclidLineCompare
    moveAB::Observable{Float32}
    moveCD::Observable{Float32}
    Pr_t::Observable{Float32}
    lw_t::Observable{Float32}
    linewidth::Float32
    cursorlinewidth::Float32
    equals::Bool
    color::Observable
    success
    fail
    drawing
end


""" Setup drawing for a line comparison (potentially to be animated)"""
function compare_lines(A::Point2f, B::Point2f,
                        C::Point2f, D::Point2f,
                        endpoint::Point2f, endθ::Float32;
                        successcolor=:green, failcolor=:red,
                        precision=10,
                        cursorcolor=:purple, color=:black, linewidth::Float32=1f0, cursorlinewidth::Float32=0f0)
    #Setup the vectors and their equality...
    vecs = [B-A, D-C]
    norms = norm.(vecs)
    θs = [sign(vec[2])*acos(vec[1]/norm(vec)) for vec in vecs]
    
    norms_r = round.(norms, digits=precision)
    linesequal = norms_r[1]==norms_r[2]

    # Create the comparison object...
    compare = EuclidLineCompare(Observable(0f0), Observable(0f0), 
                                Observable(0f0), Observable(0f0),
                                linewidth, cursorlinewidth,
                                linesequal,
                                Observable(color), successcolor, failcolor, color)

    # Get end unit vectors
    vecs_end = [endpoint - A, endpoint - C]
    norms_end = norm.(vecs_end)
    uvecs_end = vecs_end ./ norms_end

    # Calculate for line AB
    θAB_t = @lift(((endθ - θs[1]) * $(compare.moveAB)) + θs[1])
    A_t = @lift(uvecs_end[1] .* (norms_end[1] * $(compare.moveAB)) + A)
    B_t = @lift(norms[1] * [cos($θAB_t), sin($θAB_t)] + $A_t)

    # Calculate for line CD
    θCD_t = @lift(((endθ - θs[2]) * $(compare.moveCD)) + θs[2])
    C_t = @lift(uvecs_end[2] .* (norms_end[2] * $(compare.moveCD)) + C)
    D_t = @lift(norms[2] * [cos($θCD_t), sin($θCD_t)] + $C_t)

    # Finally, draw the lines, starting with the cursor wires
    if cursorlinewidth > 0
        lines!(@lift([A, $A_t]), color=cursorcolor, linewidth=(compare.Pr_t))
        lines!(@lift([B, $B_t]), color=cursorcolor, linewidth=(compare.Pr_t))

        lines!(@lift([C, $C_t]), color=cursorcolor, linewidth=(compare.Pr_t))
        lines!(@lift([D, $D_t]), color=cursorcolor, linewidth=(compare.Pr_t))
    end

    # Then draw the comparison line AB
    ABline = @lift([Point2f($A_t), Point2f($B_t)])
    lines!(ABline, color=(compare.color), linewidth=(compare.lw_t))

    # Then draw the comparison angle EDF
    CDline = @lift([Point2f($C_t), Point2f($D_t)])
    lines!(CDline, color=(compare.color), linewidth=(compare.lw_t))

    # Return the comparison object
    compare
end

""" Draw a completed line comparison for Euclid"""
function fill_linecompare(line::EuclidLineCompare)
    line.moveAB[] = 1f0
    line.moveCD[] = 1f0
    line.Pr_t[] = 1f0
    line.lw_t[] = line.linewidth
    line.color[] = line.equals == true ? line.success : line.fail
end

""" Reset drawing a line comparison so it is not shown for Euclid """
function reset_linecompare(line::EuclidLineCompare)
    line.moveAB[] = 0f0
    line.moveCD[] = 0f0
    line.Pr_t[] = 0f0
    line.lw_t[] = 0f0
    line.color[] = line.drawing
end

""" Animate the drawing of a line comparison"""
function animate_linecompare(line::EuclidLineCompare, hide_until::AbstractFloat, max_at::AbstractFloat, t::AbstractFloat;
                                fade_start::AbstractFloat=0f0, fade_end::AbstractFloat=0f0)
    if t > hide_until
        moveAB = 0f0
        moveCD = 0f0
        Pr = 0f0
        lw = 0f0
        color = line.drawing
        if t < max_at
            percmove = (t-hide_until)/(max_at-hide_until)
            moveAB = percmove < 0.5f0 ? percmove *  2f0 : 1f0
            moveCD = percmove > 0.5f0 ? (percmove - 0.5f0) * 2 : 0f0
            Pr = line.cursorlinewidth
            lw = line.linewidth
        elseif fade_start >= max_at && t > fade_start && t < fade_end
            lw = line.linewidth - line.linewidth*((t - fade_start)/(fade_end - fade_start))
            Pr = line.cursorlinewidth - line.cursorlinewidth*((t - fade_start)/(fade_end - fade_start))
            moveAB = 1
            moveCD = 1
            color = line.equals == true ? line.success : line.fail
        elseif fade_start >= max_at && t > fade_start && t >= fade_end
            lw = 0f0
            Pr = 0f0
            moveAB = 1
            moveCD = 1
            color = line.equals == true ? line.success : line.fail
        elseif t >= max_at
            lw = line.linewidth
            Pr = line.cursorlinewidth
            moveAB = 1
            moveCD = 1
            color = line.equals == true ? line.success : line.fail
        end
        line.moveAB[] = moveAB
        line.moveCD[] = moveCD
        line.Pr_t[] = Pr
        line.lw_t[] = lw
        line.color[] = color
    end
end
