//
//  GPCPolygon.m
//
//  Created by John Swensen on 3/21/14.
//  Copyright (c) 2014 John Swensen. All rights reserved.
//

#import "GPCPolygon.h"

///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
@implementation GPCPolygon


- (GPCPolygon*) init
{
    self = [super init];
    if (self) {
        
        // allocate memory for the gpcPolygon.
        //_poly = (gpc_polygon *) malloc( sizeof( gpc_polygon ));
        //if ( _poly == NULL ) return NULL;

        // Initialize with no contours and no holes.
        _poly.contour = NULL;
        _poly.hole = NULL;
        _poly.num_contours = 0;
    }
    
    return self;
}

- (GPCPolygon*) initWithPoints:(NSMutableArray*)points
{
    self = [super init];
    if (self) {
        
        // allocate memory for the gpcPolygon.
        //_poly = (gpc_polygon *) malloc( sizeof( gpc_polygon ));
        //if ( _poly == NULL ) return NULL;
        
        _poly.contour = NULL;
        _poly.hole = NULL;
        

        // Initialize with a single contour and populate it with the points from the array
        _poly.num_contours = 1;
        _poly.contour = (gpc_vertex_list *) malloc( sizeof( gpc_vertex_list ) * _poly.num_contours );
        _poly.hole = (int *)malloc( sizeof( int ) * _poly.num_contours );
        _poly.hole[0] = 0;
        
        if ( _poly.contour == NULL ) {
            gpc_free_polygon(&_poly);
            return NULL;
        }

        // allocate enough memory to hold this many points
        _poly.contour[0].num_vertices = (int) [points count];
        _poly.contour[0].vertex = (gpc_vertex *) malloc( sizeof( gpc_vertex ) * [points count] );
        for( NSInteger idx = 0; idx < [points count]; ++idx )
        {
            CGPoint pnt = [[points objectAtIndex:idx] CGPointValue];
            _poly.contour[0].vertex[idx].x = pnt.x;
            _poly.contour[0].vertex[idx].y = pnt.y;
        }
        
        // Find hole status from winding direction
        _poly.hole[0] = [self isHoleFromWinding];

    }

    return self;
}

- (GPCPolygon*) initWithVertexList:(gpc_vertex_list)points
{
    self = [super init];
    if (self) {
        
        // allocate memory for the gpcPolygon.
        //_poly = (gpc_polygon *) malloc( sizeof( gpc_polygon ));
        //if ( _poly == NULL ) return NULL;
        
        _poly.contour = NULL;
        _poly.hole = NULL;
        
        // Initialize with a single contour and populate it with the points from the gpc_vertex_list
        _poly.num_contours = 1;
        _poly.contour = (gpc_vertex_list *) malloc( sizeof( gpc_vertex_list ) * 1 );
        _poly.hole = (int *)malloc( sizeof( int ) * 1 );
        _poly.hole[0] = 0;
        
        if ( _poly.contour == NULL ) {
            gpc_free_polygon( &_poly );
            return NULL;
        }
        
        // allocate enough memory to hold this many points
        _poly.contour[0].num_vertices = (int) points.num_vertices;
        _poly.contour[0].vertex = (gpc_vertex *) malloc( sizeof( gpc_vertex ) * points.num_vertices );
        
        for( NSInteger idx = 0; idx < points.num_vertices; ++idx )
        {
            _poly.contour[0].vertex[idx].x = points.vertex[idx].x;
            _poly.contour[0].vertex[idx].y = points.vertex[idx].y;
        }
        
        // Find hole status from winding direction
        _poly.hole[0] = [self isHoleFromWinding];
        
    }
    
    return self;
}

- (BOOL) isHoleFromWinding
{
    return [self isHoleFromWindingList:_poly.contour[0]];
}

- (BOOL) isHoleFromWindingList:(gpc_vertex_list)list
{
    float areaSigned = 0.0;
    for (int i = 0 ; i < list.num_vertices ; i++)
    {
        if (i == list.num_vertices-1)
        {
            areaSigned += (list.vertex[i].x*list.vertex[0].y - list.vertex[0].x*list.vertex[i].y)/2;
        }
        else
        {
            areaSigned += (list.vertex[i].x*list.vertex[i+1].y - list.vertex[i+1].x*list.vertex[i].y)/2;
        }
    }
    return (areaSigned <= 0.0);
}

- (BOOL) isHole
{
    // FIXME?: assumes that the hole array has been allocated
    return _poly.hole[0];
}

- (int) count
{
    if (_poly.num_contours == 0)
    {
        return 0;
    }
    else
    {
        return _poly.contour[0].num_vertices;
    }
        
}

- (CGPoint) pointAtIndex:(int)idx
{
    // FIXME?: assumes that the contour array has been allocated and doesn't check index conditions.
    if (idx < 0 || idx >= [self count] )
    {
        return CGPointMake(0,0);
    }
    else
    {
        return CGPointMake(_poly.contour[0].vertex[idx].x,_poly.contour[0].vertex[idx].y);
    }
}

- (CGPoint) lastPoint
{
    // FIXME?: assumes that the contour array has been allocated
    int idx = _poly.contour[0].num_vertices-1;
    return [self pointAtIndex:idx];
}

- (void) addPoint:(CGPoint)pnt
{
    // FIXME?: assumes that the contour array has been allocated
    if (_poly.num_contours == 0)
    {
        // Initialize with a single contour and populate it with the points from the array
        _poly.num_contours = 1;
        _poly.contour = (gpc_vertex_list *) malloc( sizeof( gpc_vertex_list ) * 1 );
        _poly.hole = (int *)malloc( sizeof( int ) * 1 );
        _poly.hole[0] = 0;
        
        if ( _poly.contour == NULL ) {
            gpc_free_polygon( &_poly );
            return;
        }
        
        _poly.contour[0].num_vertices=1;
        _poly.contour[0].vertex = (gpc_vertex *) malloc(sizeof( gpc_vertex ) * _poly.contour[0].num_vertices );
        
        _poly.contour[0].vertex[0].x = pnt.x;
        _poly.contour[0].vertex[0].y = pnt.y;
    }
    else
    {
        _poly.contour[0].num_vertices++;
        _poly.contour[0].vertex = (gpc_vertex *) realloc(_poly.contour[0].vertex, sizeof( gpc_vertex ) * _poly.contour[0].num_vertices );
        
        _poly.contour[0].vertex[_poly.contour[0].num_vertices-1].x = pnt.x;
        _poly.contour[0].vertex[_poly.contour[0].num_vertices-1].y = pnt.y;
    }
    
    
}

- (void) insertPoint:(CGPoint)pnt atIndex:(int)idx
{
    // FIXME?: assumes that the contour array has been allocated
    
    
    _poly.contour[0].num_vertices++;
    _poly.contour[0].vertex = (gpc_vertex *) realloc(_poly.contour[0].vertex, sizeof( gpc_vertex ) * _poly.contour[0].num_vertices );
    
    for (int i = _poly.contour[0].num_vertices-1 ; i > idx ; i-- )
    {
        _poly.contour[0].vertex[i].x = _poly.contour[0].vertex[i-1].x;
        _poly.contour[0].vertex[i].y = _poly.contour[0].vertex[i-1].y;
    }
    _poly.contour[0].vertex[idx].x = pnt.x;
    _poly.contour[0].vertex[idx].y = pnt.y;
}

- (NSMutableArray*) toArray
{
    NSMutableArray* retval = [[NSMutableArray alloc] init];
    
    // FIXME?: assumes that the contour array has been allocated
    for (int i = 0 ; i < _poly.contour[0].num_vertices ; i++)
    {
        CGPoint pnt = CGPointMake(_poly.contour[0].vertex[i].x,
                                  _poly.contour[0].vertex[i].y);
        [retval addObject:[NSValue valueWithCGPoint:pnt]];
    }
    
    return retval;
}

- (float) area
{
    GPCPolygonSet* ps = [[GPCPolygonSet alloc] initWithPolygon:self];
    NSMutableArray* triangles = [ps triangulateWithMask:ps];
    float area = 0.0;
    for (NSMutableArray* tri in triangles)
    {
        CGPoint A = [[tri objectAtIndex:0] CGPointValue];
        CGPoint B = [[tri objectAtIndex:1] CGPointValue];
        CGPoint C = [[tri objectAtIndex:2] CGPointValue];
        
        area += abs(A.x*(B.y-C.y) + B.x*(C.y-A.y) + C.x*(A.y-B.y))/2.0;
    }
    return area;
}

- (void)dealloc
{
    //NSLog(@"Dealloc of GPCPolygon");
    gpc_free_polygon(&_poly);
}

@end




///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
@implementation GPCPolygonSet

- (GPCPolygonSet*) init
{
    self = [super init];
    if (self) {
        
        // allocate memory for the gpcPolygon.
        //_polys = (gpc_polygon *) malloc( sizeof( gpc_polygon ));
        //if ( _polys == NULL ) return NULL;
        
        // Initialize with no contours and no holes.
        _polys.contour = NULL;
        _polys.hole = NULL;
        _polys.num_contours = 0;

    }
    return self;
}

- (GPCPolygonSet*) initWithPolygons:(NSMutableArray*)inPolys
{
    self = [super init];
    if (self) {
        
        // allocate memory for the gpcPolygon.
        //_polys = (gpc_polygon *) malloc( sizeof( gpc_polygon ));
        //if ( _polys == NULL ) return NULL;
        
        _polys.contour = NULL;
        _polys.hole = NULL;
        
        // Initialize with the number of contours defined in the input array
        _polys.num_contours = (int)[inPolys count];
        _polys.contour = (gpc_vertex_list *) malloc( sizeof( gpc_vertex_list ) * _polys.num_contours );
        _polys.hole = (int *)malloc( sizeof( int ) * _polys.num_contours );
        
        if ( _polys.contour == NULL ) {
            gpc_free_polygon( &_polys );
            return NULL;
        }
        
        // allocate enough memory to hold this many points and populate the contours
        for (NSInteger idx = 0; idx < [inPolys count]; ++idx)
        {
            NSMutableArray* poly = [inPolys objectAtIndex:idx];
            
            _polys.contour[idx].num_vertices = (int) [poly count];
            _polys.contour[idx].vertex = (gpc_vertex *) malloc( sizeof( gpc_vertex ) * [poly count] );

            _polys.hole[idx] = 0; // Assumes none being created are holes
            
            for( NSInteger p = 0; p < [poly count]; ++p )
            {
                CGPoint pnt = [[poly objectAtIndex:p] CGPointValue];
                _polys.contour[idx].vertex[p].x = pnt.x;
                _polys.contour[idx].vertex[p].y = pnt.y;
            }
        }
        
        [self updateHolesFromWindingList];
    }
    
    return self;
}

- (GPCPolygonSet*) initWithPolygon:(GPCPolygon*)poly
{
    self = [super init];
    if (self) {
        
        // allocate memory for the gpcPolygon.
        //_polys = (gpc_polygon *) malloc( sizeof( gpc_polygon ));
        //if ( _polys == NULL ) return NULL;
        
        // Initialize with a single contour
        _polys.num_contours = 1;

        _polys.contour = (gpc_vertex_list *) malloc( sizeof( gpc_vertex_list ) * 1 );
        _polys.hole = (int *)malloc( sizeof( int ) * 1 );
        _polys.hole[0] = poly->_poly.hole[0];
        
        if ( _polys.contour == NULL ) {
            gpc_free_polygon( &_polys );
            return NULL;
        }
        
        // allocate enough memory to hold this many points and populate the vertex list
        _polys.contour[0].num_vertices = [poly count];
        _polys.contour[0].vertex = (gpc_vertex *) malloc( sizeof( gpc_vertex ) * [poly count] );
        
        for( int idx = 0; idx < [poly count]; ++idx )
        {
            CGPoint pnt = [poly pointAtIndex:idx];
            _polys.contour[0].vertex[idx].x = pnt.x;
            _polys.contour[0].vertex[idx].y = pnt.y;
        }
    }
    
    return self;
}

- (void) updateHolesFromWindingList
{
    for (int i = 0 ; i < _polys.num_contours ; i++)
    {
        float areaSigned = 0.0;
        for (int j = 0 ; j < _polys.contour[i].num_vertices ; j++)
        {
            if (j == _polys.contour[i].num_vertices-1)
            {
                areaSigned += (_polys.contour[i].vertex[j].x*_polys.contour[i].vertex[0].y - _polys.contour[i].vertex[0].x*_polys.contour[i].vertex[j].y)/2;
            }
            else
            {
                areaSigned += (_polys.contour[i].vertex[j].x*_polys.contour[i].vertex[j+1].y - _polys.contour[i].vertex[j+1].x*_polys.contour[i].vertex[j].y)/2;
            }
        }
        _polys.hole[i] = (areaSigned <= 0.0);
    }
}

- (void) addPolygon:(GPCPolygon*)poly
{
    if (_polys.num_contours == 0)
    {
        // Initialize with a single contour
        _polys.num_contours = 1;
        
        _polys.contour = (gpc_vertex_list *) malloc( sizeof( gpc_vertex_list ) * 1 );
        _polys.hole = (int *)malloc( sizeof( int ) * 1 );
        _polys.hole[0] = poly->_poly.hole[0];
        
        if ( _polys.contour == NULL ) {
            gpc_free_polygon( &_polys );
        }
        
        // allocate enough memory to hold this many points and populate the vertex list
        _polys.contour[0].num_vertices = [poly count];
        _polys.contour[0].vertex = (gpc_vertex *) malloc( sizeof( gpc_vertex ) * [poly count] );
        
        for( int idx = 0; idx < [poly count]; ++idx )
        {
            CGPoint pnt = [poly pointAtIndex:idx];
            _polys.contour[0].vertex[idx].x = pnt.x;
            _polys.contour[0].vertex[idx].y = pnt.y;
        }
    }
    else
    {
        // Initialize with a single contour
        _polys.num_contours++;
        
        _polys.contour = (gpc_vertex_list *) realloc(_polys.contour, sizeof( gpc_vertex_list ) * _polys.num_contours );
        _polys.hole = (int *) realloc(_polys.hole, sizeof( int ) * _polys.num_contours );
        _polys.hole[_polys.num_contours-1] = poly->_poly.hole[0];
        
        if ( _polys.contour == NULL ) {
            gpc_free_polygon( &_polys );
        }
        
        // allocate enough memory to hold this many points and populate the vertex list
        _polys.contour[_polys.num_contours-1].num_vertices = [poly count];
        _polys.contour[_polys.num_contours-1].vertex = (gpc_vertex *) malloc( sizeof( gpc_vertex ) * [poly count] );
        
        for( int idx = 0; idx < [poly count]; ++idx )
        {
            CGPoint pnt = [poly pointAtIndex:idx];
            _polys.contour[_polys.num_contours-1].vertex[idx].x = pnt.x;
            _polys.contour[_polys.num_contours-1].vertex[idx].y = pnt.y;
        }
    }
}

- (int) count
{
    return _polys.num_contours;
}

- (GPCPolygon*) polygonAtIndex:(int)idx
{
    if (idx < 0 || idx >= [self count])
        return nil;
    else
    {
        GPCPolygon* retval = [[GPCPolygon alloc] initWithVertexList:_polys.contour[idx]];
        //if (_polys.hole[idx] == 1)
        //    retval->_poly.hole[0] = 1;
        return retval;
    }
}

// This will make and array of arrays
- (NSMutableArray*) toArray
{
    NSMutableArray* retval = [[NSMutableArray alloc] init];
    
    for (int i = 0 ; i < _polys.num_contours ; i++)
    {
        NSMutableArray* poly = [[NSMutableArray alloc] init];
        for (int j = 0 ; j < _polys.contour[i].num_vertices ; j++)
        {
            CGPoint pnt = CGPointMake(_polys.contour[i].vertex[j].x,
                                      _polys.contour[i].vertex[j].y);
            [poly addObject:[NSValue valueWithCGPoint:pnt]];
        }
        
        if ([poly count]>0)
            [retval addObject:poly];
    }
    
    return retval;
}

- (GPCPolygonSet*) unionWithPolygon:(GPCPolygon*)p2
{
    GPCPolygonSet* retval = [[GPCPolygonSet alloc] init];
    gpc_polygon_clip(GPC_UNION, &_polys, &p2->_poly, &retval->_polys);
    return retval;
}

- (GPCPolygonSet*) unionWithPolygonSet:(GPCPolygonSet*)p2
{
    GPCPolygonSet* retval = [[GPCPolygonSet alloc] init];
    gpc_polygon_clip(GPC_UNION, &_polys, &p2->_polys, &retval->_polys);
    return retval;
}

- (GPCPolygonSet*) intersectWithPolygon:(GPCPolygon*)p2
{
    GPCPolygonSet* retval = [[GPCPolygonSet alloc] init];
    gpc_polygon_clip(GPC_INT, &_polys, &p2->_poly, &retval->_polys);
    return retval;

}

- (GPCPolygonSet*) intersectWithPolygonSet:(GPCPolygonSet*)p2
{
    GPCPolygonSet* retval = [[GPCPolygonSet alloc] init];
    gpc_polygon_clip(GPC_INT, &_polys, &p2->_polys, &retval->_polys);
    return retval;

}

- (GPCPolygonSet*) differenceWithPolygon:(GPCPolygon*)p2
{
    GPCPolygonSet* retval = [[GPCPolygonSet alloc] init];
    gpc_polygon_clip(GPC_DIFF, &_polys, &p2->_poly, &retval->_polys);
    return retval;

}

- (GPCPolygonSet*) differenceWithPolygonSet:(GPCPolygonSet*)p2
{
    GPCPolygonSet* retval = [[GPCPolygonSet alloc] init];
    gpc_polygon_clip(GPC_DIFF, &_polys, &p2->_polys, &retval->_polys);
    return retval;

}

- (GPCPolygonSet*) xorWithPolygon:(GPCPolygon*)p2
{
    GPCPolygonSet* retval = [[GPCPolygonSet alloc] init];
    gpc_polygon_clip(GPC_XOR, &_polys, &p2->_poly, &retval->_polys);
    return retval;

}

- (GPCPolygonSet*) xorWithPolygonSet:(GPCPolygonSet*)p2
{
    GPCPolygonSet* retval = [[GPCPolygonSet alloc] init];
    gpc_polygon_clip(GPC_XOR, &_polys, &p2->_polys, &retval->_polys);
    return retval;

}

- (NSMutableArray*) triangulateWithMask:(GPCPolygonSet*)mask
{
    NSMutableArray* retval = [[NSMutableArray alloc] init];
    gpc_tristrip t;
    gpc_tristrip_clip(GPC_INT, &_polys, &mask->_polys, &t);

    for (int i = 0 ; i < t.num_strips ; i++)
    {
        for (int j = 0 ; j < t.strip[i].num_vertices-2 ; j++) {
            NSMutableArray* tri = [[NSMutableArray alloc] init];
            [tri addObject:[NSValue valueWithCGPoint:CGPointMake(t.strip[i].vertex[j].x,t.strip[i].vertex[j].y)]];
            [tri addObject:[NSValue valueWithCGPoint:CGPointMake(t.strip[i].vertex[j+1].x,t.strip[i].vertex[j+1].y)]];
            [tri addObject:[NSValue valueWithCGPoint:CGPointMake(t.strip[i].vertex[j+2].x,t.strip[i].vertex[j+2].y)]];
            [retval addObject:tri];

        }
    }
    
    gpc_free_tristrip(&t);
    return retval;
}

- (NSMutableArray*) triangulateStripWithMask:(GPCPolygonSet*)mask
{
    NSMutableArray* retval = [[NSMutableArray alloc] init];
    gpc_tristrip t;
    gpc_tristrip_clip(GPC_INT, &_polys, &mask->_polys, &t);
    
    for (int i = 0 ; i < t.num_strips ; i++)
    {
        NSMutableArray* strip = [[NSMutableArray alloc] init];
        for (int j = 0 ; j < t.strip[i].num_vertices ; j++) {
            [strip addObject:[NSValue valueWithCGPoint:CGPointMake(t.strip[i].vertex[j].x,t.strip[i].vertex[j].y)]];
        }
        
        if ([strip count] > 0)
        {
            [retval addObject:strip];
        }
    }
    
    gpc_free_tristrip(&t);
    return retval;
}

- (float) area
{
    NSMutableArray* triangles = [self triangulateWithMask:self];
    float area = 0.0;
    for (NSMutableArray* tri in triangles)
    {
        CGPoint A = [[tri objectAtIndex:0] CGPointValue];
        CGPoint B = [[tri objectAtIndex:1] CGPointValue];
        CGPoint C = [[tri objectAtIndex:2] CGPointValue];
        
        area += abs(A.x*(B.y-C.y) + B.x*(C.y-A.y) + C.x*(A.y-B.y))/2.0;
    }
    return area;
}


- (void)dealloc
{
    //NSLog(@"Dealloc of GPCPolygonSet");
    gpc_free_polygon(&_polys);
}

@end
