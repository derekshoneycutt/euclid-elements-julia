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
    B_t::Observable{Point2f}
    Pr_t::Observable{Float32}
    lw_t::Observable{Float32}
end

""" Create the basis for a straight line in Euclid drawings -- Polar coordinates"""
function straight_line(A::Point2f, r::Float32, θ::Float32;
                        cursorcolor=:red, color=:black, linewidth::Float32=0f0)
    B = Point2f0(r*cos(θ), r*sin(θ))+A
    line = EuclidLine(A, B, r, linewidth, Observable(A), Observable(0f0), Observable(linewidth))

    lines!(@lift([A, $(line.B_t)]), color=color, linewidth=(line.lw_t))
    poly!(@lift(Circle($(line.B_t), $(line.Pr_t))), color=cursorcolor)

    line
end

""" Create the basis for a straight line in Euclid drawings -- cartesian coordinates"""
function straight_line(A::Point2f, B::Point2f;
                        cursorcolor=:red, color=:black, linewidth::Float32=0f0)
    r = norm(B-A)
    line = EuclidLine(A, B, r, linewidth, Observable(A), Observable(0f0), Observable(linewidth))

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

""" animate a line (this is an internal function specific)"""
function animate_line_(line::EuclidLine, hide_until::Float32, max_at::Float32, t::Float32;
                        fade_start::Float32=0f0, fade_end::Float32=0f0)
    if t > hide_until
        new_B = line.A
        Pr = 0f0
        lw = 0f0
        if t < max_at
            new_B = get_line(line.A, line.B, move_out=((t-hide_until)/(max_at-hide_until))*line.r)
            Pr = 0.1f0
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

""" animate a line for Euclid"""
function animate_line(line::EuclidLine, hide_until, max_at, t;
                        fade_start=0f0, fade_end=0f0)
    # we need to make sure stuff is in Float32 or hell ensues...
    animate_line_(line, Float32(hide_until), Float32(max_at), Float32(t), fade_start=Float32(fade_start), fade_end=Float32(fade_end))
end


""" Description for drawing a circle in Euclid"""
struct EuclidCircle
    A::Point2f
    r::Float32
    startθ::Float32
    linewidth::Float32
    drawwhole::Observable{Bool}
    θ::Observable{Float32}
    Pr_t::Observable{Float32}
    lw_t::Observable{Float32}
end

""" Setup drawing for a whole circle (potentially to be animated)"""
function whole_circle(A::Point2f, r::Float32, startθ::Float32;
                        cursorcolor=:red, color=:black, linewidth::Float32=1f0)
    split_θ = fix_angle(startθ)

    circle = EuclidCircle(A, r, split_θ, linewidth,
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


""" Internal function to actually animate the drawing of a circle"""
function animate_circle_(circle::EuclidCircle, hide_until::Float32, max_at::Float32, t::Float32;
                            fade_start::Float32=0f0, fade_end::Float32=0f0)
    if t > hide_until
        drawwhole = false
        θ = circle.startθ
        Pr = 0f0
        lw = 0f0
        if t < max_at
            θ = fix_angle((circle.startθ + 2π*((t-hide_until)/(max_at-hide_until))) % 2π)
            Pr = 5f0
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

""" Animate the drawing of a circle"""
function animate_circle(circle::EuclidCircle, hide_until, max_at, t;
                            fade_start=0f0, fade_end=0f0)
    # another pain in the ass convert to Float32 bs
    animate_circle_(circle, Float32(hide_until), Float32(max_at), Float32(t), fade_start=Float32(fade_start), fade_end=Float32(fade_end))
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

""" Setup drawing for a whole circle (potentially to be animated)"""
function compare_triangle(B::Point2f, A::Point2f, C::Point2f, 
                        E::Point2f, D::Point2f, F::Point2f,
                        endpoint::Point2f, endθ::Float32;
                        triangle=true, testlength=true, successcolor=:green, failcolor=:red,
                        precision=10,
                        cursorcolor=:purple, color=:black, linewidth::Float32=1f0, cursorlinewidth::Float32=0f0)
    #Setup the vectors and their equality...
    vecs = [B-A, C-A, E-D, F-D]
    norms = norm.(vecs)
    θorigins = [sign(vecs[1][2])*acos(vecs[1][1] / norms[1]),
                sign(vecs[2][2])*acos(vecs[2][1] / norms[2]),
                sign(vecs[3][2])*acos(vecs[3][1] / norms[3]),
                sign(vecs[4][2])*acos(vecs[4][1] / norms[4])]
    for (i,θ) in enumerate(θorigins)
        if θ == 0f0 && vecs[i][1] < 0
            θorigins[i] = π
        end
    end
    θs = [sign(θorigins[2] - θorigins[1])*acos((vecs[1]⋅vecs[2]) / (norms[1]*norms[2])),
            sign(θorigins[4] - θorigins[3])*acos((vecs[3]⋅vecs[4]) / (norms[3]*norms[4]))]
    
    norms_r = round.(norms, digits=precision)
    θs_r = round.(θs, digits=precision)
    ∠equal = abs(θs_r[1])==abs(θs_r[2]) && (!testlength || (norms_r[1]==norms_r[3] && norms_r[2]==norms_r[4]))

    # Create the comparison object...
    compare = EuclidTriCompare(Observable(0f0), Observable(0f0), 
                                Observable(0f0), Observable(0f0),
                                linewidth, cursorlinewidth,
                                ∠equal,
                                Observable(color), successcolor, failcolor, color)

    # Calculate for angle BAC
    A_end = endpoint-A
    Anorm_end = norm(A_end)
    Au_end = A_end/Anorm_end

    θBAC_t = @lift(((endθ - θorigins[1]) * $(compare.moveBAC)) + θorigins[1])
    A_t = @lift(Au_end .* (Anorm_end * $(compare.moveBAC)) + A)
    B_t = @lift(norms[1] * [cos($θBAC_t), sin($θBAC_t)] + $A_t)
    Cθ = @lift($θBAC_t + (θs[1] >= 0 ? θs[1] : θs[1] - ($(compare.moveBAC) * 2 * θs[1])))
    C_t = @lift(norms[2] * [cos($Cθ), sin($Cθ)] + $A_t)

    # Calculate for angle EDF
    D_end = endpoint-D
    Dnorm_end = norm(D_end)
    Du_end = D_end/Dnorm_end

    θEDF_t = @lift(((endθ - θorigins[3]) * $(compare.moveEDF)) + θorigins[3])
    D_t = @lift(Du_end .* (Dnorm_end * $(compare.moveEDF)) + D)
    E_t = @lift(norms[3] * [cos($θEDF_t), sin($θEDF_t)] + $D_t)
    Fθ = @lift($θEDF_t + (θs[2] >= 0 ? θs[2] : θs[2] - ($(compare.moveEDF) * 2 * θs[2])))
    F_t = @lift(norms[4] * [cos($Fθ), sin($Fθ)] + $D_t)

    # Finally, draw the lines, starting with the cursor wires
    if cursorlinewidth > 0
        lines!(@lift([B, $B_t]), color=cursorcolor, linewidth=(compare.Pr_t))
        lines!(@lift([A, $A_t]), color=cursorcolor, linewidth=(compare.Pr_t))
        lines!(@lift([C, $C_t]), color=cursorcolor, linewidth=(compare.Pr_t))
    end

    if cursorlinewidth > 0
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
    tri.Pr_t[] = 0f0
    tri.lw_t[] = tri.linewidth
    tri.color[] = tri.equals == true ? tri.success : tri.fail
end


""" Internal function to actually animate the drawing of a (tri)angle comparison"""
function animate_tricompare_(tri::EuclidTriCompare, hide_until::Float32, max_at::Float32, t::Float32;
                                fade_start::Float32=0f0, fade_end::Float32=0f0)
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


""" Animate the drawing of a (tri)angle comparison"""
function animate_tricompare(tri::EuclidTriCompare, hide_until, max_at, t;
                                fade_start=0f0, fade_end=0f0)
    animate_tricompare_(tri, Float32(hide_until), Float32(max_at), Float32(t), fade_start=Float32(fade_start), fade_end=Float32(fade_end))
end