using LinearAlgebra;
using Symbolics;
using Latexify;
using GLMakie;

# Find a point that will continue the given line
function continue_line(A::Point2, B::Point2, adjust_x=5)
    v = B - A
    u = v / norm(v)
    x,y = B + adjust_x*u
    Point2(x, y)
end;



# I.1 Find the third point that constructs an equilateral triangle from 2 points
function equilateral_from(A::Point2, B::Point2)
    #basically, the idea is pull the vector and rotate it 60° to find the 3rd equaliteral point
    # this is really what Euclid does!
    v = B-A
    θ = π/3
    x, y = [cos(θ) -sin(θ); sin(θ) cos(θ)]*v + A
    Point2(x, y)
end;

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
function draw_lines(triangle::EquilateralTriangle, color=:pink)
    lines!(Circle(triangle.A, triangle.r), color=color)
    lines!(Circle(triangle.B, triangle.r), color=color)
    lines!([triangle.A, triangle.B], color=color)
    D_D = Point(triangle)
    lines!([D_D, triangle.A], color=color)
    lines!([D_D, triangle.B], color=color)
end

function draw_lines(triangle::Observable{EquilateralTriangle}, color=:pink)
    lines!(@lift(Circle(Point2f(($triangle).A[1],($triangle).A[2]), ($triangle).r)), color=color)
    lines!(@lift(Circle(Point2f(($triangle).B[1],($triangle).B[2]), ($triangle).r)), color=color)
    lines!(@lift([($triangle).A, ($triangle).B]), color=color)
    lines!(@lift([Point($triangle), ($triangle).A]), color=color)
    lines!(@lift([Point($triangle), ($triangle).B]), color=color)
end


# I.2 At one given point, get a point to draw a line equal to a line from 2 given points
function equal_line(A::Point2, B::Point2, C::Point2)
    # Get an equilateral triangle, DAB
    D = equilateral_from(A,B)

    # In Euclid, we get straight lines AE, BF, straight from DA, DB -- this is redundant...
    # We just skip to finding G and L via DB extended to DG and DA extended to DL

    # Circle CGH with center B, radius BC
    r_CGH = norm(B-C)
    G = continue_line(D, B, r_CGH)

    # Circle GKL with center D, radius DG
    r_GKL = norm(D-G)
    continue_line(D, A, r_GKL - norm(D-A)) #L
end;

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


# Draw the lines for an EquilateralTriangle previously defined
function draw_lines(lines::EqualLines, color=:pink)
    draw_lines(lines.triangle)
    D = Point(lines.triangle)

    lines!([lines.A,lines.E], color=color)
    lines!([lines.B,lines.F], color=color)
    lines!(Circle(lines.B, lines.r_CGH), color=color)
    lines!(Circle(D, lines.r_GKL), color=color)
    lines!([lines.A,D], color=color)
end

function draw_lines(lines::Observable{EqualLines}, color=:pink)
    draw_lines(@lift(($lines).triangle))
    D = @lift(Point(($lines).triangle))


    lines!(@lift([Point2f(($lines).A[1],($lines).A[2]),($lines).E]), color=color)
    lines!(@lift([Point2f(($lines).B[1],($lines).B[2]),($lines).F]), color=color)
    lines!(@lift(Circle(Point2f(($lines).B[1],($lines).B[2]), ($lines).r_CGH)), color=color)
    lines!(@lift(Circle($D, ($lines).r_GKL)), color=color)
    lines!(@lift([Point2f(($lines).A[1],($lines).A[2]),$D]), color=color)
end


# I.3 Find the point that would cut a line equal 
function cut_line(A1::Point2, B1::Point2, A2::Point2, B2::Point2)
    # In Euclid, we get D to form a straight line AD the same length as C, then define circle DEF at center A, with radius AD
    # this is redundant and the radius of DEF is always norm(B2-A2), so just skip ahead :)
    r_DEF = norm(B2-A2)
    v = B1 - A1
    u = v / norm(v)
    E_x,E_y = A1 + r_DEF*u
    Point2(E_x,E_y)
end