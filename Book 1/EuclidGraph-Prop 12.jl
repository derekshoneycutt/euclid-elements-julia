
""" Represents drawing a perpendicular line from a given line to a point for Euclid """
struct EuclidPerpendicularToPoint
    EFG::EuclidCircle
    HLines::EuclidBisectLine
    HBisect::EuclidLine
    CG::EuclidLine
    CE::EuclidLine
    DoCH::Bool
    CH::EuclidLine
    H::Point2f0
end

""" Get the end point of the perpendicular line described """
function Point(perp::EuclidPerpendicularToPoint)
    perp.H
end

""" Calculate the perpendicular line from the line AB to the point C """
function perpendicular_to_point(A::Point2f0, B::Point2f0, C::Point2f0;
                        dolineCH::Bool=false,
                        cursorcolor=:red, color=:black,
                        linewidth::Float32=1f0, cursorwidth::Float32=0.025f0, cursorlw::Float32=5f0)
    # Let AB be the given infinite straight line, 
    # and C the given point which is not on it on it;

    # thus it is required to draw to the given infinite straight line AB, from the given point C
    #   which is not on it, a perpendicular straight line.

    # For let a point D be taken at random on the other side of the straight line AB,
    #       ASIDE: We just continue a line from C to the midpoint of AB and drop a lil further
    AB_norm = norm(B-A)
    AB_u = (B-A)/AB_norm
    θ_AB = vector_angle(A,B)
    AB_mid = A + [cos(θ_AB); sin(θ_AB)]*(AB_norm/2)
    D = continue_line(C, AB_mid, norm(AB_mid - C) / 2)

    # and with centre C and distance CD let the circle EFG be described; [Post. 3]
    EFG = whole_circle(C, CD_norm, vector_angle(C, D), color=color, linewidth=linewidth, cursorwidth=cursorlw)

    #       ASIDE: We need to find E and F that intersect the EFG and AB
    #               This is done with the quadratic formula acting on the formula of the line and the circle
    m = (B[2]-A[2])/(B[1]-A[1])
    b = B[2]-m*B[1]
    quad_a = m^2 + 1
    quad_b = 2*(b*m - C[1] - C[2]*m)
    quad_c = C[1]^2 + C[2]^2 - CD_norm^2 + b^2 - 2*b*C[2]
    # quad_a * x^2  + quad_b * x + quad_c = 0
    E_x = (-quad_b + √(quad_b^2 - 4*quad_a*quad_c)) / (2*quad_a)
    G_x = (-quad_b - √(quad_b^2 - 4*quad_a*quad_c)) / (2*quad_a)
    E = Point2f0(E_x, m * E_x + b)
    G = Point2f0(G_x, m * G_x + b)

    # let the straight line EG be bisected at H, [I. 10]
    H_lines = bisect_line(E, G, color=color, linewidth=linewidth, cursorlw=cursorwidth)
    H_C, H_F, H = Points(H_lines)
    H_bisect = straight_line(H_C, H_F, color=color, linewidth=linewidth, cursorwidth=cursorwidth)

    # and let the straight lines CG, CH, CE be joined. [Post. 1]
    CG = straight_line(C, G, color=color, linewidth=linewidth, cursorwidth=cursorwidth)
    CE = straight_line(C, E, color=color, linewidth=linewidth, cursorwidth=cursorwidth)
    CH = straight_line(C, H, color=:green, linewidth=linewidth, cursorwidth=cursorwidth)

    # I say that CH has been drawn perpendicular to the given infinite straight line AB
    # from the given point C which is not on it.

    # For, since GH is equal to HE, and HC is common,
    #   the two sides GH, HC are equal to the two sides EH, HC respectively;
    # and the base CG is equal to the base CE;
    #       therefore the angle CHG is equal to the angle EHC. [I. 8]
    # And they are adjacent angles.
    # But, when a straight line set up on a straight line makes the adjacent angles
    # equal to one another, each of the e3qual angles is right, and the straight line
    # standing on the other is called a perpendicular to that on which it stands. [Def. 10]

    # Therefore CH has been drawn perpendicular to the given infinite straight line AB
    # from the given point C which is not on it.

    # QEF
    EuclidPerpendicularToPoint(EFG, H_lines, H_bisect, CG, CE, dolineCH, CH, H)
end

""" Fill out the total drawing of a perpendicular line to a point operation """
function fill_perpendicular_to_point(perp::EuclidPerpendicularToPoint)
    fill_circle(perp.EFG)
    fill_bisect_line(perp.HLines)
    fill_line(perp.HBisect)
    if perp.DoCH
        fill_line(perp.CG)
        fill_line(perp.CE)
        fill_line(perp.CH)
    end
end

""" Reset drawing of a perpendicular line to a point operation """
function reset_perpendicular_to_point(perp::EuclidPerpendicularToPoint)
    reset_circle(perp.EFG)
    reset_bisect_line(perp.HLines)
    reset_line(perp.HBisect)
    if perp.DoCH
        reset_line(perp.CG)
        reset_line(perp.CE)
        reset_line(perp.CH)
    end
end

""" Animate a previously calculation of a perpendicular line to a point """
function animate_perpendicular_to_point(perp::EuclidPerpendicularToPoint, hide_until::AbstractFloat, max_at::AbstractFloat, t::AbstractFloat;
                                    fade_start::AbstractFloat=0f0, fade_end::AbstractFloat=0f0)
    d(n, ofn=6) = hide_until + (n-1)*(max_at - hide_until)/ofn
    df(n, ofn=6) = fade_start + (n-1)*(fade_end - fade_start)/ofn

    ofn = perp.DoCH ? 6 : 4

    #animate EFG
    animate_circle(perp.EFG, d(1,ofn), d(2,ofn), t, fade_start=df(1,ofn), fade_end=df(2,ofn))

    #animate H bisection
    animate_bisect_line(perp.HLines, d(2,ofn), d(3,ofn), t, fade_start=df(3,ofn), fade_end=df(4,ofn))
    animate_line(perp.HBisect, d(3,ofn), d(4,ofn), t, fade_start=df(3,ofn), fade_end=df(4,ofn))

    #animate CG, CE, CH
    if perp.DoCH
        animate_line(perp.CG, d(4,ofn), d(5,ofn), t, fade_start=df(4,ofn), fade_end=df(5,ofn))
        animate_line(perp.CE, d(4,ofn), d(5,ofn), t, fade_start=df(4,ofn), fade_end=df(5,ofn))
        animate_line(perp.CH, d(5,ofn), d(6,ofn), t, fade_start=df(5,ofn), fade_end=df(6,ofn))
    end
end
