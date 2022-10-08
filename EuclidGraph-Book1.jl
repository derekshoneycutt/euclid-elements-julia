include("EuclidMath-Book1.jl")
include("EuclidGraph-Core.jl")


""" Describe a representation of drawing an equilateral triangle via Euclid """
struct EuclidEquilTri
    A::Point2f0
    B::Point2f0
    C::Point2f0
    BCD::EuclidCircle
    ACE::EuclidCircle
    AC::EuclidLine
    BC::EuclidLine
end

""" Get the point that forms an equilateral triangle on a previously given line """
function Point(tri::EuclidEquilTri)
    tri.C
end

""" Construct an equilateral triangle on top of a given line, via Euclid """
function equilateral_triangle(A::Point2f0, B::Point2f0;
                                cursorcolor=:red, color=:black, linewidth::Float32=1f0, cursorlw=0.1f0)
    # Get the radius and vectors
    BA = A-B
    AB = B-A
    r = norm(AB)

    # Draw the circles and then the lines that Euclid describes
    BCD = whole_circle(A, r, sign(AB[2])*acos(AB[1]/r), cursorcolor=cursorcolor, color=color, linewidth=linewidth)
    ACE = whole_circle(B, r, sign(BA[2])*acos(BA[1]/r), cursorcolor=cursorcolor, color=color, linewidth=linewidth)
    C = equilateral_from(A, B)
    AC = straight_line(A, C, cursorcolor=cursorcolor, color=color, linewidth=linewidth, cursorwidth=cursorlw)
    BC = straight_line(B, C, cursorcolor=cursorcolor, color=color, linewidth=linewidth, cursorwidth=cursorlw)

    EuclidEquilTri(A, B, C, BCD, ACE, AC, BC)
end

""" Fill out the drawing of an equilateral triangle by Euclid """
function fill_equilateral(tri::EuclidEquilTri)
    fill_circle(tri.BCD)
    fill_circle(tri.ACE)
    fill_line(tri.AC)
    fill_line(tri.BC)
end

 """Actual inside drawing method for animating drawing an equilateral triangle by Euclid"""
function animate_equilateral_(tri::EuclidEquilTri, hide_until::Float32, max_at::Float32, t::Float32;
                                fade_start::Float32=0f0, fade_end::Float32=0f0)
    d(n, ofn=4) = hide_until + (n-1)*(max_at - hide_until)/ofn
    animate_circle(tri.BCD, d(1), d(2), t, fade_start=fade_start, fade_end=fade_end)
    animate_circle(tri.ACE, d(2), d(3), t, fade_start=fade_start, fade_end=fade_end)
    animate_line(tri.AC, d(3), d(4), t, fade_start=fade_start, fade_end=fade_end)
    animate_line(tri.BC, d(4), d(5), t, fade_start=fade_start, fade_end=fade_end)
end

 """Animate the drawing of an equilateral triangle by Euclid"""
function animate_equilateral(tri::EuclidEquilTri, hide_until, max_at, t;
                                fade_start=0f0, fade_end=0f0)
    animate_equilateral_(tri, Float32(hide_until), Float32(max_at), Float32(t),
                            fade_start=Float32(fade_start), fade_end=Float32(fade_end))
end



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
                        cursorcolor=:red, color=:black, linewidth::Float32=1f0)
    # Get the point D forming an equilateral triangle
    D = equilateral_triangle(A, B, cursorcolor=cursorcolor, color=color, linewidth=linewidth)
    Dpoint = Point(D)

    # Get straight lines AE, BF, straight from DA, DB
    CB = B-C
    r_CGH = norm(CB)
    E = continue_line(Dpoint, A, r_CGH*2)
    F = continue_line(Dpoint, B, r_CGH*2)

    # Circle CGH with center B, radius BC
    G = continue_line(Dpoint, B, r_CGH)

    # Circle GKL with center D, radius DG
    GD = Dpoint-G
    r_GKL = norm(GD)
    L = continue_line(Dpoint, A, r_GKL - norm(Dpoint-A))

    AB = straight_line(A, B, cursorcolor=cursorcolor, color=color, linewidth=linewidth)
    CGH = whole_circle(B, r_CGH, sign(CB[2])*acos(CB[1]/r_CGH), cursorcolor=cursorcolor, color=color, linewidth=linewidth)
    GKL = whole_circle(Dpoint, r_GKL, sign(GD[2])*acos(GD[1]/r_GKL), cursorcolor=cursorcolor, color=color, linewidth=linewidth)
    DE = straight_line(Dpoint, E, cursorcolor=cursorcolor, color=color, linewidth=linewidth)
    DF = straight_line(Dpoint, F, cursorcolor=cursorcolor, color=color, linewidth=linewidth)

    EuclidEqualLine(A, B, C, D, CGH, GKL, AB, DE, DF, L)
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

""" Inside animation method for animate drawing equal line by Euclid"""
function animate_equivalent_(line::EuclidEqualLine, hide_until::Float32, max_at::Float32, t::Float32;
                                fade_start::Float32=0f0, fade_end::Float32=0f0)
    d(n, ofn=6) = hide_until + (n-1)*(max_at - hide_until)/ofn
    animate_line(line.AB, d(1), d(2), t, fade_start=fade_start, fade_end=fade_end)
    animate_equilateral(line.D, d(2), d(3), t, fade_start=d(4), fade_end=max_at)
    animate_line(line.DE, d(3), d(4), t, fade_start=fade_start, fade_end=fade_end)
    animate_line(line.DF, d(4), d(5), t, fade_start=fade_start, fade_end=fade_end)
    animate_circle(line.CGH, d(5), d(6), t, fade_start=fade_start, fade_end=fade_end)
    animate_circle(line.GKL, d(6), max_at, t, fade_start=fade_start, fade_end=fade_end)
end

""" Animate drawing an equivalent line by Euclid"""
function animate_equivalent(line::EuclidEqualLine, hide_until, max_at, t;
                                fade_start=0f0, fade_end=0f0)
    animate_equivalent_(line, Float32(hide_until), Float32(max_at), Float32(t),
                                fade_start=Float32(fade_start), fade_end=Float32(fade_end))
end


""" Represent Euclid's method for cutting a line into a segment equal to another, shorter line"""
struct EuclidCutLine
    A::Point2f0
    B::Point2f0
    C1::Point2f0
    C2::Point2f0
    EqualLine::EuclidEqualLine
    DEF::EuclidCircle
    AD::EuclidLine
    E::Point2f0
end

""" Get a point that completes a EuclidCutLine representation"""
function Point(line::EuclidCutLine)
    line.E
end

""" Setup drawing for cutting one line equal to another shorter one"""
function draw_cut_line(A::Point2f0, B::Point2f0, C1::Point2f0, C2::Point2f0;
                        cursorcolor=:red, color=:black, linewidth::Float32=1f0)
    # Draw an equivalent line, then draw a circle based on that equivalent line, cutting AB by the radius
    EqualLine = equivalent_line(A, C1, C2, cursorcolor=cursorcolor, color=color, linewidth=linewidth)
    D = Point(EqualLine)

    AD = D-A
    r_DEF = norm(AD)
    AB = B - A
    u = AB / norm(AB)
    E = A + r_DEF*u

    DEF = whole_circle(A, r_DEF, -acos(AD[1]/r_DEF), cursorcolor=cursorcolor, color=color, linewidth=linewidth)
    AD = straight_line(A, D, cursorcolor=cursorcolor, color=color, linewidth=linewidth)

    EuclidCutLine(A, B, C1, C2, EqualLine, DEF, AD, E)
end


""" Inside animation to animate drawing cutting one line equal to another shorter"""
function animate_cut_line_(line::EuclidCutLine, hide_until::Float32, max_at::Float32, t::Float32;
                                fade_start::Float32=0f0, fade_end::Float32=0f0)
    d(n, ofn=3) = hide_until + (n-1)*(max_at - hide_until)/ofn
    animate_equivalent(line.EqualLine, d(1), d(2), t, fade_start=d(2.5), fade_end=max_at)
    animate_line(line.AD, d(2), d(3), t, fade_start=fade_start, fade_end=fade_end)
    animate_circle(line.DEF, d(3), max_at, t, fade_start=fade_start, fade_end=fade_end)
end

""" Animate everything to show a line being cut equal to another, shorter one"""
function animate_cut_line(line::EuclidCutLine, hide_until, max_at, t;
                                fade_start=0f0, fade_end=0f0)
    animate_cut_line_(line, Float32(hide_until), Float32(max_at), Float32(t),
                                fade_start=Float32(fade_start), fade_end=Float32(fade_end))
end
