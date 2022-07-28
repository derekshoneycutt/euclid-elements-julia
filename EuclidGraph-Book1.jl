include("EuclidMath-Book1.jl")
include("EuclidGraph-Core.jl")


# Representation of an equilateral triangle in space
struct EquilateralTriangle
    A::Point2
    B::Point2
    r::Float32
    v::Point2
    θ::Float32
    x::Float32
    y::Float32
end

# Get a point from an equilateral triangle representation
function Point(tri::EquilateralTriangle)
    return Point2f(tri.x,tri.y)
end

# I.1 Find the third point that constructs an equilateral triangle from 2 points
function EquilateralTriangle_from(A::Point2, B::Point2)
    #basically, the idea is pull the vector and rotate it 60° to find the 3rd equaliteral point
    # this is really what Euclid does!
    v = B-A
    r = norm(v)
    θ = π/3
    x, y = [cos(θ) -sin(θ); sin(θ) cos(θ)]*v + A
    EquilateralTriangle(A, B, r, v, θ, x, y)
end;

# Draw the lines for an EquilateralTriangle previously defined
function draw_lines(triangle::EquilateralTriangle; color=:pink)
    lines!(Circle(triangle.A, triangle.r), color=color)
    lines!(Circle(triangle.B, triangle.r), color=color)
    lines!([triangle.A, triangle.B], color=color)
    D_D = Point(triangle)
    lines!([D_D, triangle.A], color=color)
    lines!([D_D, triangle.B], color=color)
end

# Draw lines given an observable equilateral triangle
function draw_lines(triangle::Observable{EquilateralTriangle}; color=:pink)
    lines!(@lift(Circle(Point2f(($triangle).A[1],($triangle).A[2]), ($triangle).r)), color=color)
    lines!(@lift(Circle(Point2f(($triangle).B[1],($triangle).B[2]), ($triangle).r)), color=color)
    lines!(@lift([($triangle).A, ($triangle).B]), color=color)
    lines!(@lift([Point($triangle), ($triangle).A]), color=color)
    lines!(@lift([Point($triangle), ($triangle).B]), color=color)
end

# Define an observable group of colors to draw an equilateral triangle
struct EquilateralTriangleColors
    CircleA::Observable{RGBA}
    CircleB::Observable{RGBA}
    AC::Observable{RGBA}
    BC::Observable{RGBA}
    FillPoly::Observable{RGBA}
end

# Initiate an observable group of colors according to some basic definitions
function init_equilateral_colors(hide::Bool, linecol::RGB, fillcol::RGB)
    EquilateralTriangleColors(
        Observable(RGBA(linecol[1], linecol[2], linecol[3], hide ? 0.0 : 1.0)),
        Observable(RGBA(linecol[1], linecol[2], linecol[3], hide ? 0.0 : 1.0)),
        Observable(RGBA(linecol[1], linecol[2], linecol[3], hide ? 0.0 : 1.0)),
        Observable(RGBA(linecol[1], linecol[2], linecol[3], hide ? 0.0 : 1.0)),
        Observable(RGBA(fillcol[1], fillcol[2], fillcol[3], hide ? 0.0 : 1.0)))
end

# Draw lines given an observable equilateral triangle
function draw_lines(triangle::Observable{EquilateralTriangle}, colors::EquilateralTriangleColors)
    lw = 0.25
    lines!(@lift(Circle(Point2f(($triangle).A[1],($triangle).A[2]), ($triangle).r)), color=colors.CircleA, linewidth=lw, transparency=true)
    lines!(@lift(Circle(Point2f(($triangle).B[1],($triangle).B[2]), ($triangle).r)), color=colors.CircleB, linewidth=lw, transparency=true)
    lines!(@lift([Point($triangle), ($triangle).A]), color=colors.AC, linewidth=lw, transparency=true)
    lines!(@lift([Point($triangle), ($triangle).B]), color=colors.BC, linewidth=lw, transparency=true)
    poly!(@lift([($triangle).A, Point($triangle), ($triangle).B]), color=colors.FillPoly, transparency=true)
end

# Update equilateral triangle colors according to a time schedule
function update_colors(colors::EquilateralTriangleColors, hide_until, max_at, t; fade_start=0, fade_end=0, stay_poly=true)
    if t < hide_until
        # Hide it all!
        colors.CircleA[] = RGBA(colors.CircleA[].r, colors.CircleA[].g, colors.CircleA[].b, 0.0)
        colors.CircleB[] = RGBA(colors.CircleB[].r, colors.CircleB[].g, colors.CircleB[].b, 0.0)
        colors.AC[] = RGBA(colors.AC[].r, colors.AC[].g, colors.AC[].b, 0.0)
        colors.BC[] = RGBA(colors.BC[].r, colors.BC[].g, colors.BC[].b, 0.0)
        colors.FillPoly[] = RGBA(colors.FillPoly[].r, colors.FillPoly[].g, colors.FillPoly[].b, 0.0)
    elseif t <= max_at
        # Fade in the lines and into the full poly
        dt = max_at - hide_until
        curr_dt = (t - hide_until)/dt
        colors.CircleA[] = RGBA(colors.CircleA[].r, colors.CircleA[].g, colors.CircleA[].b, 1/(1+ℯ^-100(curr_dt-0.125)))
        colors.CircleB[] = RGBA(colors.CircleB[].r, colors.CircleB[].g, colors.CircleB[].b, 1/(1+ℯ^-100(curr_dt-0.375)))
        colors.AC[] = RGBA(colors.AC[].r, colors.AC[].g, colors.AC[].b, 1/(1+ℯ^-100(curr_dt-0.625)))
        colors.BC[] = RGBA(colors.BC[].r, colors.BC[].g, colors.BC[].b, 1/(1+ℯ^-100(curr_dt-0.625)))
        colors.FillPoly[] = RGBA(colors.FillPoly[].r, colors.FillPoly[].g, colors.FillPoly[].b, 1/(1+ℯ^-100(curr_dt-0.875)))
    end
end




# Representation of a line and another line that is equal to it, drawn from another point
struct EqualLines
    A::Point2
    B::Point2
    C::Point2
    triangle::EquilateralTriangle
    r_CGH::Float32
    r_GKL::Float32
    E::Point2
    F::Point2
    L::Point2
end

# Get a point that completes a EqualLines representation
function Point(lines::EqualLines)
    return lines.L
end

# Figure out how to draw an equal line from another point and return a representation
function EqualLines_from(A::Point2, B::Point2, C::Point2)
    # Get the equilateral triangle
    triangle = EquilateralTriangle_from(A,B)
    D = Point(triangle)

    # Get straight lines AE, BF, straight from DA, DB
    r_CGH = norm(B-C)
    E = continue_line(D, A, r_CGH + 2)
    F = continue_line(D, B, r_CGH + 2)

    # Circle CGH with center B, radius BC
    G = continue_line(D, B, r_CGH)

    # Circle GKL with center D, radius DG
    r_GKL = norm(D-G)
    L = continue_line(D, A, r_GKL - norm(D-A))

    EqualLines(A, B, C, triangle, r_CGH, r_GKL, E, F, L)
end


# Draw the lines for an EqualLines previously defined
function draw_lines(lines::EqualLines; color=:pink)
    draw_lines(lines.triangle, color=color)
    D = Point(lines.triangle)

    lines!([lines.A,lines.E], color=color)
    lines!([lines.B,lines.F], color=color)
    lines!(Circle(lines.B, lines.r_CGH), color=color)
    lines!(Circle(D, lines.r_GKL), color=color)
    lines!([lines.A,D], color=color)
end

# Draw the lines given an observable EqualLines
function draw_lines(lines::Observable{EqualLines}; color=:pink)
    draw_lines(@lift(($lines).triangle), color=color)
    D = @lift(Point(($lines).triangle))


    lines!(@lift([Point2f(($lines).A[1],($lines).A[2]),($lines).E]), color=color)
    lines!(@lift([Point2f(($lines).B[1],($lines).B[2]),($lines).F]), color=color)
    lines!(@lift(Circle(Point2f(($lines).B[1],($lines).B[2]), ($lines).r_CGH)), color=color)
    lines!(@lift(Circle($D, ($lines).r_GKL)), color=color)
    lines!(@lift([Point2f(($lines).A[1],($lines).A[2]),$D]), color=color)
end





# Representation of a cut line equal to another line
struct CutLine
    A::Point2
    B::Point2
    C1::Point2
    C2::Point2
    D::EqualLines
    r::Float32
    v::Point2
    u::Point2
    E::Point2
end

# Get a point that completes a CutLine representation
function Point(cut::CutLine)
    return cut.E
end

# I.3 Find the point that would cut a line equal 
function CutLine_from(A::Point2, B::Point2, C1::Point2, C2::Point2)
    D = EqualLines_from(A, C1, C2)

    r = norm(A-Point(D))
    v = B - A
    u = v / norm(v)
    E = A + r*u

    CutLine(A, B, C1, C2, D, r, v, u, E)
end

# Draw the background lines for cutting a line equal to another
function draw_lines(cut::CutLine; color=:pink)
    # Draw all those lines.... meeeep
    draw_lines(cut.D, color=color)

    lines!([cut.A,cut.B], color=color)
    lines!([cut.C1,cut.C2], color=color)
    lines!([cut.A,cut.E], color=color)
    lines!([cut.A,Point(cut.D)], color=color)
    lines!(Circle(cut.A, cut.r),color=color)
    lines!([cut.A,cut.E], color=color)
end

# Draw the background lines according to observable CutLine data
function draw_lines(cut::Observable{CutLine}; color=:pink)
    # Draw all those lines.... meeeep
    draw_lines(@lift(($cut).D), color=color)

    lines!(@lift([($cut).A,($cut).B]), color=color)
    lines!(@lift([($cut).C1,($cut).C2]), color=color)
    lines!(@lift([($cut).A,($cut).E]), color=color)
    lines!(@lift([($cut).A,Point(($cut).D)]), color=color)
    lines!(@lift(Circle(($cut).A, ($cut).r)),color=color)
    lines!(@lift([($cut).A,($cut).E]), color=color)
end
