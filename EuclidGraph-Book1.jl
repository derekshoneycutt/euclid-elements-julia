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
    getsign(x) = x >= 0 ? 1 : -1
    BCD = whole_circle(A, r, getsign(AB[2])*acos(AB[1]/r), cursorcolor=cursorcolor, color=color, linewidth=linewidth)
    ACE = whole_circle(B, r, getsign(BA[2])*acos(BA[1]/r), cursorcolor=cursorcolor, color=color, linewidth=linewidth)
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

    getsign(x) = x >= 0 ? 1 : -1
    AB = straight_line(A, B, cursorcolor=cursorcolor, color=color, linewidth=linewidth)
    CGH = whole_circle(B, r_CGH, getsign(CB[2])*acos(CB[1]/r_CGH), cursorcolor=cursorcolor, color=color, linewidth=linewidth)
    GKL = whole_circle(Dpoint, r_GKL, getsign(GD[2])*acos(GD[1]/r_GKL), cursorcolor=cursorcolor, color=color, linewidth=linewidth)
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

""" Fill out the drawing of a cut line, in all of its parts """
function fill_cut_line(line::EuclidCutLine)
    fill_equivalent(line.EqualLine)
    fill_line(line.AD)
    fill_circle(line.DEF)
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



""" Representation of an animation for bisecting an angle """
struct EuclidBisectAngle
    AE_circle::EuclidCircle
    ED::EuclidLine
    D_lines::EuclidEquilTri
    F::Point2f0
end

""" Gets the point that a line can be drawn between the origin of the angle and to get a line bisecting the angle """
function Point(bisect::EuclidBisectAngle)
    bisect.F
end

""" Calculate the bisection of a given angle, with A as the origin and B and C as points along opposite sides """
function bisect_angle(A::Point2f0, B::Point2f0, C::Point2f0;
                        cursorcolor=:red, color=:black, linewidth::Float32=1f0, cursorlw::Float32=0.025f0)
    #Let the angle BAC be the given recilineal angle
    AB = B-A
    AC = C-A
    norm_B = norm(AB)
    norm_C = norm(AC)

    #aside: get angle BAC w/ calculus
    getsign(x) = x >= 0 ? 1 : -1
    fix_θ_0(vec, θ) = getsign(vec[2])*(θ == 0f0 && vec[1] < 0 ? π : θ)
    B_θ = fix_θ_0(AB, acos(AB[1] / norm_B))
    C_θ = fix_θ_0(AC, acos(AC[1] / norm_C))
    θsign(angle1, angle2) = getsign(fix_angle(angle1) - fix_angle(angle2))
    θ = θsign(C_θ, B_θ)*acos((AB⋅AC) / (norm_B*norm_C))

    #Thus it is required to bisect it
    #Let a point D be taken at random on AB
    #   We will choose the shorter of the length of B or C as vectors from A to decide
    norm_D = min(norm_B, norm_C)
    D = AB * norm_D / norm_B + A

    #let AE be cut off from AC equal to AD  [I.3]
    AE_circle = whole_circle(A, norm_D, B_θ, color=color, linewidth=linewidth, cursorcolor=cursorcolor)
    E = AC * norm_D / norm_C + A

    #let DE be joined
    ED = straight_line(E, D, color=color, linewidth=linewidth, cursorcolor=cursorcolor, cursorwidth=cursorlw)

    #and on DE let the equilateral triangle DEF be constructed.
    # funny point: need to figure out what direction the angle is pointing and draw the equilateral accordingly
    ED_mid = (D + E) ./ 2
    EDtoA = A - ED_mid
    DE_vec = E-D
    if (EDtoA[1] < 0 && DE_vec[2] > 0) || (EDtoA[1] > 0 && DE_vec[2] < 0)
        D_lines = equilateral_triangle(E, D, color=color, linewidth=linewidth, cursorcolor=cursorcolor, cursorlw=cursorlw)
    else
        D_lines = equilateral_triangle(D, E, color=color, linewidth=linewidth, cursorcolor=cursorcolor, cursorlw=cursorlw)
    end
    F = Point(D_lines)

    EuclidBisectAngle(AE_circle, ED, D_lines, F)
end

""" Fill out the total drawing of a bisect angle operation """
function fill_bisect_angle(bisect::EuclidBisectAngle)
    fill_circle(bisect.AE_circle)
    fill_line(bisect.ED)
    fill_equilateral(bisect.D_lines)
end

""" Animate a previously calculation of a bisected angle """
function animate_bisect_angle_(bisect::EuclidBisectAngle, hide_until::Float32, max_at::Float32, t::Float32;
                                    fade_start::Float32=0f0, fade_end::Float32=0f0)
    d(n, ofn=3) = hide_until + (n-1)*(max_at - hide_until)/ofn
    df(n, ofn=3) = fade_start + (n-1)*(fade_end - fade_start)/ofn
    #animate AE
    animate_circle(bisect.AE_circle, d(1), d(2), t, fade_start=df(1), fade_end=df(2))

    #Animate DE
    animate_line(bisect.ED, d(2), d(3), t, fade_start=df(2), fade_end=fade_end)

    #Animate DEF
    animate_equilateral(bisect.D_lines, d(3), d(4), t, fade_start=df(3), fade_end=fade_end)
end

""" Animate a previously calculation of a bisected angle """
function animate_bisect_angle(bisect::EuclidBisectAngle, hide_until, max_at, t;
                                    fade_start=0f0, fade_end=0f0)
    animate_bisect_angle_(bisect, Float32(hide_until), Float32(max_at), Float32(t),
                                    fade_start=Float32(fade_start), fade_end=Float32(fade_end))
end


""" Represents drawing a bisection of a finite line for Euclid """
struct EuclidBisectLine
    ABC::EuclidEquilTri
    CD::EuclidBisectAngle
end

""" Get the end points of the bisecting line described """
function Points(bisect::EuclidBisectLine)
    [Point(bisect.ABC), Point(bisect.CD)]
end

""" Calculate the bisection of a given finite line, given by endpoints A and B """
function bisect_line(A::Point2f0, B::Point2f0;
                        cursorcolor=:red, color=:black, linewidth::Float32=1f0, cursorlw::Float32=0.025f0)
    # Let AB be the given finite straight line
    #Thus it is required to bisect the finite straight line AB.
    #Let the equilateral triangle ABC be constructed on it [I.1],
    ABC = equilateral_triangle(A, B, cursorcolor=cursorcolor, color=color, linewidth=linewidth, cursorlw=cursorlw)
    C = Point(ABC)

    #and let the angle ACB be bisected by the straight line CD [I.9];
    CD = bisect_angle(C, B, A, cursorcolor=cursorcolor, color=color, linewidth=linewidth, cursorlw=cursorlw)

    #I say that the straight line AB has been bisected at the point D.

    #For, since AC is equal to CB, and CD is common,
    #  the two sides AC, CD are equal to the two sides BC, CD respectively;
    #and the angle ACD is equal to the angle BCD;
    #    therefore the base AD is equal to the base BD [I.4]

    #Therefore the given finite straight line has been bisected at D.

    #QEF
    EuclidBisectLine(ABC, CD)
end

""" Fill out the total drawing of a bisect line operation """
function fill_bisect_line(bisect::EuclidBisectLine)
    fill_equilateral(bisect.ABC)
    fill_bisect_angle(bisect.CD)
end

""" Animate a previously calculation of a bisected line """
function animate_bisect_line_(bisect::EuclidBisectLine, hide_until::Float32, max_at::Float32, t::Float32;
                                    fade_start::Float32=0f0, fade_end::Float32=0f0)
    d(n, ofn=2) = hide_until + (n-1)*(max_at - hide_until)/ofn
    df(n, ofn=2) = fade_start + (n-1)*(fade_end - fade_start)/ofn
    #animate ABC
    animate_equilateral(bisect.ABC, d(1), d(2), t, fade_start=df(1), fade_end=df(2))

    #Animate CD
    animate_bisect_angle(bisect.CD, d(2), max_at, t, fade_start=df(2), fade_end=fade_end)
end

""" Animate a previously calculation of a bisected line """
function animate_bisect_line(bisect::EuclidBisectLine, hide_until, max_at, t;
                                    fade_start=0f0, fade_end=0f0)
    animate_bisect_line_(bisect, Float32(hide_until), Float32(max_at), Float32(t),
                                    fade_start=Float32(fade_start), fade_end=Float32(fade_end))
end


