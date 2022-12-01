
""" Representation of an animation for comparing 2 triangles """
struct EuclidTriCompare
    moveBAC::Observable{Float32}
    moveEDF::Observable{Float32}
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


""" Calculate an angle for comparison triangles, including 3 points representing angle, in terms of time t """
function calc_∠_for_comp_triangle(endpoint, endθ, origin, θorigin, t::Observable{Float32}, θ, normB, normC, B, C)
    calc_end = endpoint - origin
    calcnorm_end = norm(calc_end)
    calcu_end = calc_end / calcnorm_end

    calc_t = @lift(calcu_end .* (calcnorm_end * $t) + origin)

    B_end = (normB * [cos(endθ), sin(endθ)] + endpoint) - B
    Bnorm_end = norm(B_end)
    calcB_end = B_end / Bnorm_end
    B_t = @lift(calcB_end .* (Bnorm_end * $t) + B)

    Cθ = endθ + (θ >= 0 ? θ : θ - (2 * θ))
    C_end = (normC * [cos(Cθ), sin(Cθ)] + endpoint) - C
    Cnorm_end = norm(C_end)
    calcC_end = C_end / Cnorm_end
    C_t = @lift(calcC_end .* (Cnorm_end * $t) + C)

    (calc_t, B_t, C_t)
end

""" Setup drawing for a (tri)angle comparison (potentially to be animated)"""
function compare_triangle(B::Point2f, A::Point2f, C::Point2f, 
                            E::Point2f, D::Point2f, F::Point2f,
                            endpoint::Point2f, endθ::Float32;
                            triangle=true, testlength=true, successcolor=:green, failcolor=:red,
                            precision=10,
                            cursorcolor=:purple, color=:black, linewidth::Float32=1f0, cursorlinewidth::Float32=0f0)
    #Setup the vectors and their equality...
    vecs = [B-A, C-A, E-D, F-D]
    norms = norm.(vecs)
    θorigins = fix_angle.([vector_angle(A, B), vector_angle(A, C), vector_angle(D, E), vector_angle(D, F)])

    # This is the angles that we are working with (comparing and moving), and need a lil helper functions to find the sign of those angles
    θsign(angle1, angle2) = sign(fix_angle(angle1) - fix_angle(angle2))
    θs = [θsign(θorigins[2], θorigins[1])*acos((vecs[1]⋅vecs[2]) / (norms[1]*norms[2])),
            θsign(θorigins[4], θorigins[3])*acos((vecs[3]⋅vecs[4]) / (norms[3]*norms[4]))]
    
    norms_r = round.(norms, digits=precision)
    θs_r = round.(θs, digits=precision)
    ∠equal = abs(θs_r[1])==abs(θs_r[2]) && (!testlength || (norms_r[1]==norms_r[3] && norms_r[2]==norms_r[4]))

    # Create the comparison object...
    compare = EuclidTriCompare(Observable(0f0), Observable(0f0), 
                                Observable(0f0), Observable(0f0),
                                linewidth, cursorlinewidth,
                                ∠equal,
                                Observable(color), successcolor, failcolor, color)

    # Calculate the angle in terms of time for animations
    (A_t, B_t, C_t) = calc_∠_for_comp_triangle(endpoint, endθ, A, θorigins[1], compare.moveBAC, θs[1], norms[1], norms[2], B, C)
    (D_t, E_t, F_t) = calc_∠_for_comp_triangle(endpoint, endθ, D, θorigins[3], compare.moveEDF, θs[2], norms[3], norms[4], E, F)

    # Finally, draw the lines, starting with the cursor wires
    if cursorlinewidth > 0
        lines!(@lift([B, $B_t]), color=cursorcolor, linewidth=(compare.Pr_t))
        lines!(@lift([A, $A_t]), color=cursorcolor, linewidth=(compare.Pr_t))
        lines!(@lift([C, $C_t]), color=cursorcolor, linewidth=(compare.Pr_t))

        lines!(@lift([E, $E_t]), color=cursorcolor, linewidth=(compare.Pr_t))
        lines!(@lift([D, $D_t]), color=cursorcolor, linewidth=(compare.Pr_t))
        lines!(@lift([F, $F_t]), color=cursorcolor, linewidth=(compare.Pr_t))
    end

    # Then draw the comparison angle BAC
    BACline = triangle ? 
                @lift([Point2f($B_t), Point2f($A_t), Point2f($C_t), Point2f($B_t), Point2f($A_t)]) :
                @lift([Point2f($B_t), Point2f($A_t), Point2f($C_t)])
    lines!(BACline, color=(compare.color), linewidth=(compare.lw_t))

    # Then draw the comparison angle EDF
    EDFline = triangle ? 
                @lift([Point2f($E_t), Point2f($D_t), Point2f($F_t), Point2f($E_t), Point2f($D_t)]) :
                @lift([Point2f($E_t), Point2f($D_t), Point2f($F_t)])
    lines!(EDFline, color=(compare.color), linewidth=(compare.lw_t))

    # Return the comparison object
    compare
end

""" Draw a completed triangle comparison for Euclid"""
function fill_tricompare(tri::EuclidTriCompare)
    tri.moveBAC[] = 1f0
    tri.moveEDF[] = 1f0
    tri.Pr_t[] = tri.cursorlinewidth
    tri.lw_t[] = tri.linewidth
    tri.color[] = tri.equals == true ? tri.success : tri.fail
end

""" Animate the drawing of a (tri)angle comparison"""
function animate_tricompare(tri::EuclidTriCompare, hide_until::AbstractFloat, max_at::AbstractFloat, t::AbstractFloat;
                                fade_start::AbstractFloat=0f0, fade_end::AbstractFloat=0f0)
    if t > hide_until
        moveBAC = 0f0
        moveEDF = 0f0
        Pr = 0f0
        lw = 0f0
        color = tri.drawing
        if t < max_at
            percmove = (t-hide_until)/(max_at-hide_until)
            moveBAC = percmove < 0.5f0 ? percmove *  2f0 : 1f0
            moveEDF = percmove > 0.5f0 ? (percmove - 0.5f0) * 2 : 0f0
            Pr = tri.cursorlinewidth
            lw = tri.linewidth
        elseif fade_start >= max_at && t > fade_start && t < fade_end
            lw = tri.linewidth - tri.linewidth*((t - fade_start)/(fade_end - fade_start))
            Pr = tri.cursorlinewidth - tri.cursorlinewidth*((t - fade_start)/(fade_end - fade_start))
            moveBAC = 1
            moveEDF = 1
            color = tri.equals == true ? tri.success : tri.fail
        elseif fade_start >= max_at && t > fade_start && t >= fade_end
            lw = 0f0
            Pr = 0f0
            moveBAC = 1
            moveEDF = 1
            color = tri.equals == true ? tri.success : tri.fail
        elseif t >= max_at
            lw = tri.linewidth
            Pr = tri.cursorlinewidth
            moveBAC = 1
            moveEDF = 1
            color = tri.equals == true ? tri.success : tri.fail
        end
        tri.moveBAC[] = moveBAC
        tri.moveEDF[] = moveEDF
        tri.Pr_t[] = Pr
        tri.lw_t[] = lw
        tri.color[] = color
    end
end

