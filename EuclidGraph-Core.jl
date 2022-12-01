include("EuclidMath-Book1.jl")
using Symbolics;
using Latexify;
using Colors;
using GLMakie;

""" Describe drawing a line for Euclid functions"""
struct EuclidLine
    A::Point2f
    B::Point2f
    r::Float32
    linewidth::Float32
    cursorwidth::Float32
    B_t::Observable{Point2f}
    Pr_t::Observable{Float32}
    lw_t::Observable{Float32}
end

""" Create the basis for a straight line in Euclid drawings -- Polar coordinates"""
function straight_line(A::Point2f, r::Float32, θ::Float32;
                        cursorcolor=:red, color=:black, linewidth::Float32=0f0, cursorwidth::Float32=0.1f0)
    B = Point2f0(r*cos(θ), r*sin(θ))+A
    line = EuclidLine(A, B, r, linewidth, cursorwidth, Observable(A), Observable(0f0), Observable(linewidth))

    lines!(@lift([A, $(line.B_t)]), color=color, linewidth=(line.lw_t))
    poly!(@lift(Circle($(line.B_t), $(line.Pr_t))), color=cursorcolor)

    line
end

""" Create the basis for a straight line in Euclid drawings -- cartesian coordinates"""
function straight_line(A::Point2f, B::Point2f;
                        cursorcolor=:red, color=:black, linewidth::Float32=0f0, cursorwidth::Float32=0.1f0)
    r = norm(B-A)
    line = EuclidLine(A, B, r, linewidth, cursorwidth, Observable(A), Observable(0f0), Observable(linewidth))

    lines!(@lift([A, $(line.B_t)]), color=color, linewidth=(line.lw_t))
    poly!(@lift(Circle($(line.B_t), $(line.Pr_t))), color=cursorcolor)

    line
end

""" Show a total, filled line"""
function fill_line(line::EuclidLine)
    new_B = get_line(line.A, line.B, move_out=-1)
    Pr = 0f0
    lw = line.linewidth
    line.B_t[] = new_B
    line.Pr_t[] = Pr
    line.lw_t[] = lw
end

""" animate a line for Euclid"""
function animate_line(line::EuclidLine, hide_until::AbstractFloat, max_at::AbstractFloat, t::AbstractFloat;
                        fade_start::AbstractFloat=0.0, fade_end::AbstractFloat=0.0)
    if t > hide_until
        new_B = line.A
        Pr = 0f0
        lw = 0f0
        if t < max_at
            new_B = get_line(line.A, line.B, move_out=((t-hide_until)/(max_at-hide_until))*line.r)
            Pr = line.cursorwidth
            lw = line.linewidth
        elseif fade_start >= max_at && t > fade_start && t < fade_end
            new_B = get_line(line.A, line.B, move_out=-1)
            lw = line.linewidth - line.linewidth*((t - fade_start)/(fade_end - fade_start))
        elseif fade_start >= max_at && t > fade_start && t >= fade_end
            lw = 0f0
            new_B = line.A
        elseif t >= max_at
            new_B = get_line(line.A, line.B, move_out=-1)
            lw = line.linewidth
        end
        line.B_t[] = new_B
        line.Pr_t[] = Pr
        line.lw_t[] = lw
    end
end


""" Description for drawing a circle in Euclid"""
struct EuclidCircle
    A::Point2f
    r::Float32
    startθ::Float32
    linewidth::Float32
    cursorwidth::Float32
    drawwhole::Observable{Bool}
    θ::Observable{Float32}
    Pr_t::Observable{Float32}
    lw_t::Observable{Float32}
end

""" Setup drawing for a whole circle (potentially to be animated)"""
function whole_circle(A::Point2f, r::Float32, startθ::Float32;
                        cursorcolor=:red, color=:black, linewidth::Float32=1f0, cursorwidth::Float32=5f0)
    split_θ = fix_angle(startθ)

    circle = EuclidCircle(A, r, split_θ, linewidth, cursorwidth,
                        Observable(false), Observable(split_θ),
                        Observable(0f0), Observable(0f0))

    P = @lift(Point2f0(r*cos($(circle.θ)) + A[1], r*sin($(circle.θ)) + A[2]))

    get_angles(currθ, forcedraw) = begin
        angles = []
        if forcedraw
            angles = 0:π/180:2π
        else
            use_θ = currθ < split_θ ? currθ + 2π : currθ
            angles = split_θ:π/180:use_θ
        end
        Vector{Float32}(angles)
    end
    point_from_angle(angle) = Point2f0(r*cos(angle)+A[1], r*sin(angle)+A[2])
    get_points(angles) = point_from_angle.(angles)

    angles = @lift(get_angles($(circle.θ), $(circle.drawwhole)))
    points = @lift(get_points($angles))

    lines!(points, color=color, linewidth=(circle.lw_t))

    lines!(@lift([A, $P]), color=cursorcolor, linewidth=(circle.Pr_t))

    circle
end

""" Draw a completed circle for Euclid"""
function fill_circle(circle::EuclidCircle)
    circle.drawwhole[] = true
    circle.Pr_t[] = 0f0
    circle.lw_t[] = (circle.linewidth)
end


""" Animate the drawing of a circle"""
function animate_circle(circle::EuclidCircle, hide_until::AbstractFloat, max_at::AbstractFloat, t::AbstractFloat;
                            fade_start::AbstractFloat=0.0, fade_end::AbstractFloat=0.0)
    if t > hide_until
        drawwhole = false
        θ = circle.startθ
        Pr = 0f0
        lw = 0f0
        if t < max_at
            θ = fix_angle((circle.startθ + 2π*((t-hide_until)/(max_at-hide_until))) % 2π)
            Pr = circle.cursorwidth
            lw = circle.linewidth
        elseif fade_start >= max_at && t > fade_start && t < fade_end
            drawwhole=true
            lw = circle.linewidth - circle.linewidth*((t - fade_start)/(fade_end - fade_start))
        elseif fade_start >= max_at && t > fade_start && t >= fade_end
            drawwhole=true
            lw = 0f0
        elseif t >= max_at
            drawwhole=true
            lw = circle.linewidth
        end
        circle.θ[] = θ
        circle.drawwhole[] = drawwhole
        circle.Pr_t[] = Pr
        circle.lw_t[] = lw
    end
end



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
