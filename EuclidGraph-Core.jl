include("EuclidMath-Book1.jl")
using Symbolics;
using Latexify;
using Colors;
using GLMakie;

# Describe drawing a line for Euclid functions
struct EuclidLine
    A::Point2f
    B::Point2f
    r::Float32
    linewidth::Float32
    B_t::Observable{Point2f}
    Pr_t::Observable{Float32}
    lw_t::Observable{Float32}
end

# Create the basis for a straight line in Euclid drawings -- Polar coordinates
function straight_line(A::Point2f, r::Float32, θ::Float32;
                        cursorcolor=:red, color=:black, linewidth::Float32=0f0)
    B = Point2f(r*cos(θ), r*sin(θ))+A
    line = EuclidLine(A, B, r, linewidth, Observable(A), Observable(0f0), Observable(linewidth))

    lines!(@lift([A, $(line.B_t)]), color=color, linewidth=(line.lw_t))
    poly!(@lift(Circle($(line.B_t), $(line.Pr_t))), color=cursorcolor)

    line
end

# Create the basis for a straight line in Euclid drawings -- cartesian coordinates
function straight_line(A::Point2f, B::Point2f;
                        cursorcolor=:red, color=:black, linewidth::Float32=0f0)
    r = norm(B-A)
    line = EuclidLine(A, B, r, linewidth, Observable(A), Observable(0f0), Observable(linewidth))

    lines!(@lift([A, $(line.B_t)]), color=color, linewidth=(line.lw_t))
    poly!(@lift(Circle($(line.B_t), $(line.Pr_t))), color=cursorcolor)

    line
end

# Show a total, filled line
function fill_line(line::EuclidLine)
    new_B = get_line(line.A, line.B, -1)
    Pr = 0f0
    lw = line.linewidth
    line.B_t[] = new_B
    line.Pr_t[] = Pr
    line.lw_t[] = lw
end

# animate a line (this is an internal function specific)
function animate_line_(line::EuclidLine, hide_until::Float32, max_at::Float32, t::Float32;
                        fade_start::Float32=0f0, fade_end::Float32=0f0)
    if t > hide_until
        new_B = line.A
        Pr = 0f0
        lw = 0f0
        if t < max_at
            new_B = get_line(line.A, line.B, ((t-hide_until)/(max_at-hide_until))*line.r)
            Pr = 0.1f0
            lw = line.linewidth
        elseif fade_start >= max_at && t > fade_start && t < fade_end
            new_B = get_line(line.A, line.B, -1)
            lw = line.linewidth - line.linewidth*((t - fade_start)/(fade_end - fade_start))
        elseif fade_start >= max_at && t > fade_start && t >= fade_end
            lw = 0f0
            new_B = line.A
        elseif t >= max_at
            new_B = get_line(line.A, line.B, -1)
            lw = line.linewidth
        end
        line.B_t[] = new_B
        line.Pr_t[] = Pr
        line.lw_t[] = lw
    end
end

# animate a line for Euclid
function animate_line(line::EuclidLine, hide_until, max_at, t;
                        fade_start=0f0, fade_end=0f0)
    # we need to make sure stuff is in Float32 or hell ensues...
    animate_line_(line, Float32(hide_until), Float32(max_at), Float32(t), fade_start=Float32(fade_start), fade_end=Float32(fade_end))
end


# Description for drawing a circle in Euclid
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

# Setup drawing for a whole circle (potentially to be animated)
function whole_circle(A::Point2f, r::Float32, startθ::Float32;
                        cursorcolor=:red, color=:black, linewidth::Float32=1f0)
    split_θ = fix_angle(startθ)

    circle = EuclidCircle(A, r, split_θ, linewidth,
                        Observable(false), Observable(split_θ),
                        Observable(0f0), Observable(0f0))

    P = @lift(Point2f(r*cos($(circle.θ)) + A[1], r*sin($(circle.θ)) + A[2]))

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

# Draw a completed circle for Euclid
function fill_circle(circle::EuclidCircle)
    circle.drawwhole[] = true
    circle.Pr_t[] = 0f0
    circle.lw_t[] = (circle.linewidth)
end


# Internal function to actually animate the drawing of a circle
function animate_circle_(circle::EuclidCircle, hide_until::Float32, max_at::Float32, t::Float32;
                        fade_start::Float32=0f0, fade_end::Float32=0f0)
    if t > hide_until
        drawwhole = false
        θ = circle.startθ
        Pr = 0f0
        lw = 0f0
        if t < max_at
            θ = fix_angle(circle.startθ + 2π*((t-hide_until)/(max_at-hide_until)))
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

# Animate the drawing of a circle
function animate_circle(circle::EuclidCircle, hide_until, max_at, t;
                            fade_start=0f0, fade_end=0f0)
    # another pain in the ass convert to Float32 bs
    animate_circle_(circle, Float32(hide_until), Float32(max_at), Float32(t), fade_start=Float32(fade_start), fade_end=Float32(fade_end))
end
