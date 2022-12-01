
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
