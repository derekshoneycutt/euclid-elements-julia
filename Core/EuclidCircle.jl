include("../EuclidMath-Book1.jl")

using Symbolics;
using Latexify;
using Colors;
using GLMakie;


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
