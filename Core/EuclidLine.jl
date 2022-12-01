include("../EuclidMath-Book1.jl")
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
