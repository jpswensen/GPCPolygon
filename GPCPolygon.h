//
//  GPCPolygon.h
//
//  Created by John Swensen on 3/21/14.
//  Copyright (c) 2014 John Swensen. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "gpc.h"

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
@interface GPCPolygon : NSObject
{
    @public
    gpc_polygon* _poly;
}

/*! Initialize a polygon with a vector of points values
 * @param points An array of CGPoints wrapped in an NSValue object (assumed to be outer ring).
 */
- (GPCPolygon*) initWithPoints:(NSMutableArray*)points;

/*! Initialize a polygon with a GPC vertex list.
 * @param points A gpc_vertex_list of points (assumed to be outer ring).
 */
- (GPCPolygon*) initWithVertexList:(gpc_vertex_list)points;

/*! Determine the hole status of the polygon.
 */
- (BOOL) isHole;

/*! Determine the number of points in the polygon.
 */
- (int) count;

/*! Retrieve the i-th point as a CGPoint.
 * @param idx The index of the point to retrieve.
 */
- (CGPoint) pointAtIndex:(int)idx;

/*! Retrieve the last point as a CGPoint.
 */
- (CGPoint) lastPoint;

/*! Add a point to the end of the polygon points.
 * @param pnt The CGPoint to add to the polygon.
 */
- (void) addPoint:(CGPoint)pnt;

/*! Insert a point to the end of the polygon points.
 * @param pnt The CGPoint to insert into the polygon.
 * @param idx The index at which the point should be inserted.
 */
- (void) insertPoint:(CGPoint)pnt atIndex:(int)idx;

/*! Return the points of the polygon as CGPoints wrapped in an array of NSValue objects.
 */
- (NSMutableArray*) toArray;

@end


///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
@interface GPCPolygonSet : NSObject
{
    @public
    gpc_polygon* _polys;
}

/*! Initialize a set of polygons with an array of arrays of points values.
 * @param points An array of arrays containing CGPoints wrapped in an NSValue object.
 */
- (GPCPolygonSet*) initWithPolygons:(NSMutableArray*)points;

/*! Initialize a set of polygons with a single GPCPolygon.
 * @param poly The polygon to add to the set.
 */
- (GPCPolygonSet*) initWithPolygon:(GPCPolygon*)poly;

/*! Determine the number of polygons in the set.
 */
- (int) count;

/*! Retrieve the i-th polygon from the set
 * @param idx The index of the polygon to be retrieved.
 */
- (GPCPolygon*) polygonAtIndex:(int)idx;

/*! Return the polygons in the set and an array of arrays containing CGPoints wrapped in an NSValue object.
 */
- (NSMutableArray*) toArray;

/*! Union a polygon with the polygon set and return a new polygon set.
 * @param p2 The polygon to union with the current set.
 */
- (GPCPolygonSet*) unionWithPolygon:(GPCPolygon*)p2;

/*! Union a polygon set with the existing polygon set and return a new polygon set.
 * @param p2 The polygon set to union with the current set.
 */
- (GPCPolygonSet*) unionWithPolygonSet:(GPCPolygonSet*)p2;

/*! Intersect a polygon with the polygon set and return a new polygon set.
 * @param p2 The polygon to intersect with the current set.
 */
- (GPCPolygonSet*) intersectWithPolygon:(GPCPolygon*)p2;

/*! Intersect a polygon set with the polygon set and return a new polygon set.
 * @param p2 The polygon set to intersect with the current set.
 */
- (GPCPolygonSet*) intersectWithPolygonSet:(GPCPolygonSet*)p2;

/*! Difference a polygon from the polygon set and return a new polygon set.
 * @param p2 The polygon to difference from the current set.
 */
- (GPCPolygonSet*) differenceWithPolygon:(GPCPolygon*)p2;

/*! Difference a polygon set from the polygon set and return a new polygon set.
 * @param p2 The polygon set to difference from the current set.
 */
- (GPCPolygonSet*) differenceWithPolygonSet:(GPCPolygonSet*)p2;

/*! Exclusive-or a polygon with the polygon set and return a new polygon set.
 * @param p2 The polygon to exclusive-or with the current set.
 */
- (GPCPolygonSet*) xorWithPolygon:(GPCPolygon*)p2;

/*! Exclusive-or a polygon set with the polygon set and return a new polygon set.
 * @param p2 The polygon set to exclusive-or with the current set.
 */
- (GPCPolygonSet*) xorWithPolygonSet:(GPCPolygonSet*)p2;

/*! Mask the polygon set with a masking set and return the triangulated result as an array of arrays each containging three CGPoints wrapped in NSValue objects.
 * @param mask The polygon set to mask the current set with before triangulating.
 */
- (NSMutableArray*) triangulateWithMask:(GPCPolygonSet*)mask;

/*! Mask the polygon set with a masking set and return the triangulated result (given as an OpenGL triangle strip) as an array of arrays each containging three CGPoints wrapped in NSValue objects.
 * @param mask The polygon set to mask the current set with before triangulating.
 */
- (NSMutableArray*) triangulateStripWithMask:(GPCPolygonSet*)mask;

@end
