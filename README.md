GPCPolygon
==========

A fairly thin wrapper for the General Polygon Clipper library (http://www.cs.man.ac.uk/~toby/alan/software/).

You should be able to just drop this in the same directory as the gpc.h and gpc.c files and start using the wrapper. Remember that GPC is free for noncommerical and student use, but requires a license for commercial use (and gladly accepts donations even for the non-commercial user).

I have to say that I tried Boost.Polygon, ClipperLib, Boost.Geometry, and GEOS, and they all had little quirks. On the other hand, GPC has "just worked" in every possible situation I have found, including self-intersections, close points, parallel edges, etc.
