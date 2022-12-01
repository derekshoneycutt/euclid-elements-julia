include("../EuclidMath-Book1.jl")
include("../EuclidGraph-Core.jl")

include("EuclidGraph-Prop 01.jl")

""" Represent drawing one line equal to another, existing line, by Euclid """
struct EuclidEqualLine
    A::Point2f0
    B::Point2f0
    C::Point2f0
    D::EuclidEquilTri
    CGH::EuclidCircle
    GKL::EuclidCircle
    AB::EuclidLine
    DE::EuclidLine
    DF::EuclidLine
    L::Point2f0
end

""" Get a point that completes a EuclidEqualLine representation"""
function Point(line::EuclidEqualLine)
    line.L
end

""" Setup drawing for an equal line by Euclid"""
function equivalent_line(A::Point2f0, B::Point2f0, C::Point2f0;
                        cursorcolor=:red, color=:black, linewidth::Float32=1f0, cursorlw::Float32=0.1f0)
    # Let A be a given point, and BC the given straight line

    # Thus it is required to place at the point A [as an extremity] a straight line equal to the given straight line BC.

    # From the point A to the point B let the straight line AB be joined; [Post. 1]
    AB = straight_line(A, B, cursorcolor=cursorcolor, color=color, linewidth=linewidth, cursorwidth=cursorlw)
    # and on it let the equilateral triangle DAB be constructed. [I. 1]
    DAB = equilateral_triangle(A, B, cursorcolor=cursorcolor, color=color, linewidth=linewidth, cursorlw=cursorlw)
    D = Point(DAB)

    # Let the straight lines AE, BF be produced in a straight line with DA, DB; [Post. 2]
    r_BC = norm(B-C)
    E = continue_line(D, A, r_BC*1.5)
    AE = straight_line(A, E, cursorcolor=cursorcolor, color=color, linewidth=linewidth, cursorwidth=cursorlw)
    F = continue_line(D, B, r_BC*1.5)
    BF = straight_line(B, F, cursorcolor=cursorcolor, color=color, linewidth=linewidth, cursorwidth=cursorlw)

    # with centre B and distance BC let the circle CGH be described; [Post. 3]
    r_CGH = norm(B-C)
    CGH = whole_circle(B, r_CGH, vector_angle(B, C), cursorcolor=cursorcolor, color=color, linewidth=linewidth)
    #       ASIDE: H is an arbitrary spot on CGH, but G is an intersection point of CGH and BF
    G = continue_line(D, B, r_CGH)

    # and again, with centre D and distance DG let the circle GKL be described. [Post. 3]
    r_GKL = norm(D-G)
    GKL = whole_circle(D, r_GKL, vector_angle(D, G), cursorcolor=cursorcolor, color=color, linewidth=linewidth)
    #       ASIDE: Again, K is an arbitrary spot on GKL, L is the intersection of GKL and AE
    L = continue_line(D, A, r_GKL - norm(D-A))

    # Then, since the point B is the centre of the circle CGH,
    #   BC is equal to BG.
    # Again, since the point D is the centre of the circle GKL,
    #   DL is equal to DG.
    # And in these DA is equal to DB;
    #   therefore the remainder AL is equal to the remainder BG [C.N. 3]

    # But BC was also proved equal to BG;
    #   therefore each of the straight lines AL, BC is equal to BG.
    # And things which are equal to the same thing are also equal to one another; [C.N. 1]
    #   therefore AL is also equal to BC.

    # Therefore at the given point A the straight line AL is placed equal to the given straight line BC.

    # Being what it was required to do.

    EuclidEqualLine(A, B, C, DAB, CGH, GKL, AB, AE, BF, L)
end

""" Draw everything out, fully, for an equal line, by Euclid"""
function fill_equivalent(line::EuclidEqualLine)
    fill_line(line.AB)
    fill_equilateral(line.D)
    fill_line(line.DE)
    fill_line(line.DF)
    fill_circle(line.CGH)
    fill_circle(line.GKL)
end

""" Animate drawing an equivalent line by Euclid"""
function animate_equivalent(line::EuclidEqualLine, hide_until::AbstractFloat, max_at::AbstractFloat, t::AbstractFloat;
                                fade_start::AbstractFloat=0f0, fade_end::AbstractFloat=0f0)
    d(n, ofn=6) = hide_until + (n-1)*(max_at - hide_until)/ofn
    animate_line(line.AB, d(1), d(2), t, fade_start=fade_start, fade_end=fade_end)
    animate_equilateral(line.D, d(2), d(3), t, fade_start=d(4), fade_end=max_at)
    animate_line(line.DE, d(3), d(4), t, fade_start=fade_start, fade_end=fade_end)
    animate_line(line.DF, d(4), d(5), t, fade_start=fade_start, fade_end=fade_end)
    animate_circle(line.CGH, d(5), d(6), t, fade_start=fade_start, fade_end=fade_end)
    animate_circle(line.GKL, d(6), max_at, t, fade_start=fade_start, fade_end=fade_end)
end
