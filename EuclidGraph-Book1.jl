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

""" Construct an equilateral triangle on top of a given line AB, via Euclid """
function equilateral_triangle(A::Point2f0, B::Point2f0;
                                cursorcolor=:red, color=:black, linewidth::Float32=1f0, cursorlw=0.1f0)
    # Let AB be the given finite straight line

    # Thus it is required to construct an equilateral triangle on the straight line AB.
    # With center A and distance AB let the circle BCD be described; [Post. 3]
    r = norm(B-A)
    startθ1 = vector_angle(A, B)
    BCD = whole_circle(A, r, startθ1, cursorcolor=cursorcolor, color=color, linewidth=linewidth)

    # again, with centre B and distance BA let the circle ACE be described; [Post. 3]
    startθ2 = vector_angle(B, A)
    ACE = whole_circle(B, r, startθ2, cursorcolor=cursorcolor, color=color, linewidth=linewidth)

    # and from the point C, in which the circles cut one another, 
    # to the points A, B let the straight lines CA, CB be joined [Post. 1]
    #           ASIDE: this is unit circle 60° * r because equilateral triangles have 3 60° angles
    C = equilateral_from(A, B)
    CA = straight_line(C, A, cursorcolor=cursorcolor, color=color, linewidth=linewidth, cursorwidth=cursorlw)
    CB = straight_line(C, B, cursorcolor=cursorcolor, color=color, linewidth=linewidth, cursorwidth=cursorlw)

    # Now, since the point A is the centre of the circle CDB, AC is equal to AB. [Def. 15]
    # Again, since the point B is the ccentre of the circle CAE, BC is equal to BA. [Def. 15]

    # But CA was also proved equal to AB; therefore each of the straight lines CA, CB is equal to AB.

    # And things which are equal to the same thing are also equal to one another; [C.N. 1]
    #   therefore CA is also equal to CB.

    # Therefore the three straight lines CA, AB, BC are equal to one another.
    # Therefore the triangle ABC is equilateral; and it has been constructed on the given finite straight line AB.

    # Being what it was required to do.

    EuclidEquilTri(A, B, C, BCD, ACE, CA, CB)
end

""" Fill out the drawing of an equilateral triangle by Euclid """
function fill_equilateral(tri::EuclidEquilTri)
    fill_circle(tri.BCD)
    fill_circle(tri.ACE)
    fill_line(tri.AC)
    fill_line(tri.BC)
end

 """Animate the drawing of an equilateral triangle by Euclid"""
function animate_equilateral(tri::EuclidEquilTri, hide_until::AbstractFloat, max_at::AbstractFloat, t::AbstractFloat;
                                fade_start::AbstractFloat=0f0, fade_end::AbstractFloat=0f0)
    d(n, ofn=4) = hide_until + (n-1)*(max_at - hide_until)/ofn
    animate_circle(tri.BCD, d(1), d(2), t, fade_start=fade_start, fade_end=fade_end)
    animate_circle(tri.ACE, d(2), d(3), t, fade_start=fade_start, fade_end=fade_end)
    animate_line(tri.AC, d(3), d(4), t, fade_start=fade_start, fade_end=fade_end)
    animate_line(tri.BC, d(4), d(5), t, fade_start=fade_start, fade_end=fade_end)
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



""" Represent Euclid's method for cutting a line into a segment equal to another, shorter line"""
struct EuclidCutLine
    A::Point2f0
    B::Point2f0
    C1::Point2f0
    C2::Point2f0
    EqualLine::EuclidEqualLine
    DEF::EuclidCircle
    E::Point2f0
end

""" Get a point that completes a EuclidCutLine representation"""
function Point(line::EuclidCutLine)
    line.E
end

""" Setup drawing for cutting one line equal to another shorter one"""
function draw_cut_line(A::Point2f0, B::Point2f0, C1::Point2f0, C2::Point2f0;
                        cursorcolor=:red, color=:black, linewidth::Float32=1f0, cursorlw::Float32=0.1f0)
    # Let AB, C be the two given unequal straight lines, and let AB be the greater of them.

    # Thus it is required to cut off from AB the greater a straight line equal to C the less.

    # At the point A let AD be placed equal to the straight line C; [I.2]
    AD = equivalent_line(A, C1, C2, cursorcolor=cursorcolor, color=color, linewidth=linewidth, cursorlw=cursorlw)
    D = Point(AD)

    # and with centre A and distance AD let hte circle DEF be described. [Post. 3]
    #           ASIDE: F is an arbitrary point on the circle, E is the intersection of AB and DEF
    r_DEF = norm(A-D)
    v = B - A
    u = v / norm(v)
    E = A + r_DEF*u
    DEF = whole_circle(A, r_DEF, vector_angle(A, E), cursorcolor=cursorcolor, color=color, linewidth=linewidth)
    #F = Point2f(r_DEF/2f0, -r_DEF*(√3f0)/2f0)

    # Now, since the point A is the centre of the circle DEF,
    #   AE is equal to AD. [Def. 15]

    # But C is also equal to AD.
    # Therefore each of the straight lines AE, C is equal to AD;
    #   so that AE is also equal to C. [C.N. 1]

    # Therefore, given the two straight lines AB, C, from AB the greater AE has been cut off equal to C the less.

    # Being what it was required to do

    EuclidCutLine(A, B, C1, C2, AD, DEF, E)
end

""" Fill out the drawing of a cut line, in all of its parts """
function fill_cut_line(line::EuclidCutLine)
    fill_equivalent(line.EqualLine)
    fill_circle(line.DEF)
end

""" Animate everything to show a line being cut equal to another, shorter one"""
function animate_cut_line(line::EuclidCutLine, hide_until::AbstractFloat, max_at::AbstractFloat, t::AbstractFloat;
                                fade_start::AbstractFloat=0f0, fade_end::AbstractFloat=0f0)
    d(n, ofn=2) = hide_until + (n-1)*(max_at - hide_until)/ofn
    animate_equivalent(line.EqualLine, d(1), d(2), t, fade_start=d(2.5), fade_end=max_at)
    animate_circle(line.DEF, d(2), max_at, t, fade_start=fade_start, fade_end=fade_end)
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

    #and let AF be joined
    
    #For, since AD is equal to AE,
    # and AF is common, 
    #   the two sides DA, AF are equal to the two sides EA, AF respectively,
    #And the base DF is equal to the base EF,
    #     therefore the angle DAF is equal to the angle EAF. [I.8]

    #Therefore the given recilineal angle BAC has been bisected by the straight line AF.

    #QEF

    EuclidBisectAngle(AE_circle, ED, D_lines, F)
end

""" Fill out the total drawing of a bisect angle operation """
function fill_bisect_angle(bisect::EuclidBisectAngle)
    fill_circle(bisect.AE_circle)
    fill_line(bisect.ED)
    fill_equilateral(bisect.D_lines)
end

""" Animate a previously calculation of a bisected angle """
function animate_bisect_angle(bisect::EuclidBisectAngle, hide_until::AbstractFloat, max_at::AbstractFloat, t::AbstractFloat;
                                    fade_start::AbstractFloat=0f0, fade_end::AbstractFloat=0f0)
    d(n, ofn=3) = hide_until + (n-1)*(max_at - hide_until)/ofn
    df(n, ofn=3) = fade_start + (n-1)*(fade_end - fade_start)/ofn
    #animate AE
    animate_circle(bisect.AE_circle, d(1), d(2), t, fade_start=df(1), fade_end=df(2))

    #Animate DE
    animate_line(bisect.ED, d(2), d(3), t, fade_start=df(2), fade_end=fade_end)

    #Animate DEF
    animate_equilateral(bisect.D_lines, d(3), d(4), t, fade_start=df(3), fade_end=fade_end)
end


""" Represents drawing a bisection of a finite line for Euclid """
struct EuclidBisectLine
    ABC::EuclidEquilTri
    CD::EuclidBisectAngle
end

""" Get the end points and middle point of the bisecting line described """
function Points(bisect::EuclidBisectLine)
    C = Point(bisect.ABC)
    F = Point(bisect.CD)
    bisection = (C .+ F) ./ 2
    [C, F, bisection]
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
function animate_bisect_line(bisect::EuclidBisectLine, hide_until::AbstractFloat, max_at::AbstractFloat, t::AbstractFloat;
                                    fade_start::AbstractFloat=0f0, fade_end::AbstractFloat=0f0)
    d(n, ofn=2) = hide_until + (n-1)*(max_at - hide_until)/ofn
    df(n, ofn=2) = fade_start + (n-1)*(fade_end - fade_start)/ofn
    #animate ABC
    animate_equilateral(bisect.ABC, d(1), d(2), t, fade_start=df(1), fade_end=df(2))

    #Animate CD
    animate_bisect_angle(bisect.CD, d(2), max_at, t, fade_start=df(2), fade_end=fade_end)
end


