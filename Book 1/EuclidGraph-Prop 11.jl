
""" Represents drawing a bisection of a finite line for Euclid """
struct EuclidPerpendicular
    DE::EuclidCircle
    DEF::EuclidEquilTri
end

""" Get the end point of the perpendicular line described """
function Point(perp::EuclidPerpendicular)
    Point(perp.DEF)
end

""" Calculate the perpendicular line from a point C on a given line, AB """
function perpendicular(A::Point2f0, B::Point2f0, C::Point2f0;
                        cursorcolor=:red, color=:black,
                        linewidth::Float32=1f0, cursorwidth::Float32=0.025f0)
    # Let AB be the given straight line, and C the given point on it.
    
    # ASIDE : some useful info about AC and AB
    AC = C-A
    AC_norm = norm(AC)
    AC_θ = vector_angle(A, C)

    # Thus it is required to draw from the point C a straight line at right angles to the straight line AB.

    # Let a point D be taken at random on AC;
    #AD_norm = rand(Uniform(0f0, AC_norm))
    # We will actually choose the halfway point for predictability
    AD_norm = AC_norm/2
    D = Point2f0(AD_norm*[cos(AC_θ), sin(AC_θ)] + A)

    # let CE be made equal to CD; [I.3]
    CD_norm = AC_norm - AD_norm
    E = Point2f0(CD_norm*[cos(AC_θ), sin(AC_θ)] + C)
    DE = whole_circle(C, AC_norm-AD_norm, vector_angle(C, D), cursorcolor=cursorcolor, color=color, linewidth=linewidth, cursorwidth=cursorwidth)

    # on DE let the equilateral triangle FDE be constructed. [I.1]
    DEF = equilateral_triangle(D, E, cursorcolor=cursorcolor, color=color, linewidth=linewidth, cursorlw=cursorwidth, circlecursorlw=cursorwidth)


    # and let FC be joined;


    # I say that the straight line FC has been drawn at right angles to 
    #   the given straight line AB from C the given point on it.
    # For, since DC is equal to CE, and CF is common,
    # the two sides DC, CF are equal to the two sides EC, CF respectively;
    # and the base DF is equal to the base FE;
    # therefore the angle DCF is equal to the angle ECF; [I.8]
    # and they are adjacent angles.

    # But, when a straight line set up on a straight line makes the adjacent angles
    #   equal to one another, each of the equal angles is right; [Def. 10]
    # therefore each of the angles DCF, FCE is right.

    # Therefore the straight line CF has been drawn at right angles to the given
    #   straight line AB from the given point C on it.

    #QEF
    EuclidPerpendicular(DE, DEF)
end

""" Fill out the total drawing of a perpendicular operation """
function fill_perpendicular(perp::EuclidPerpendicular)
    fill_circle(perp.DE)
    fill_equilateral(perp.DEF)
end

""" Animate a previously calculation of a perpendicular line """
function animate_perpendicular(perp::EuclidPerpendicular, hide_until::AbstractFloat, max_at::AbstractFloat, t::AbstractFloat;
                                    fade_start::AbstractFloat=0f0, fade_end::AbstractFloat=0f0)
    d(n, ofn=3) = hide_until + (n-1)*(max_at - hide_until)/ofn
    df(n, ofn=3) = fade_start + (n-1)*(fade_end - fade_start)/ofn
    #animate DE
    animate_circle(perp.DE, d(1), d(2), t, fade_start=df(1), fade_end=df(2))

    #animate DEF
    animate_equilateral(perp.DEF, d(2), d(3), t, fade_start=df(2), fade_end=df(3))
end
