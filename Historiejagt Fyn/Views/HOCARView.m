//
//  HOCARView.m
//  Created by Gert Lavsen on 14/02/15.
//  Copyright (c) 2015 House of Code. All rights reserved.


#import "HOCARView.h"
#import <AVFoundation/AVFoundation.h>
#import "HOCARViewPoi.h"
#include <math.h>

#pragma mark -
#pragma mark Math utilities declaration

#define DEGREES_TO_RADIANS (M_PI/180.0)

typedef float mat4f_t[16];  // 4x4 matrix in column major order
typedef float vec4f_t[4];   // 4D vector

// Creates a projection matrix using the given y-axis field-of-view, aspect ratio, and near and far clipping planes
void createProjectionMatrix(mat4f_t mout, float fovy, float aspect, float zNear, float zFar);

// Matrix-vector and matrix-matricx multiplication routines
void multiplyMatrixAndVector(vec4f_t vout, const mat4f_t m, const vec4f_t v);
void multiplyMatrixAndMatrix(mat4f_t c, const mat4f_t a, const mat4f_t b);

// Initialize mout to be an affine transform corresponding to the same rotation specified by m
void transformFromCMRotationMatrix(vec4f_t mout, const CMRotationMatrix *m);

#pragma mark -
#pragma mark Geodetic utilities declaration

#define WGS84_A (6378137.0)             // WGS 84 semi-major axis constant in meters
#define WGS84_E (8.1819190842622e-2)    // WGS 84 eccentricity

// Converts latitude, longitude to ECEF coordinate system
void latLonToEcef(double lat, double lon, double alt, double *x, double *y, double *z);

// Coverts ECEF to ENU coordinates centered at given lat, lon
void ecefToEnu(double lat, double lon, double x, double y, double z, double xr, double yr, double zr, double *e, double *n, double *u);

#pragma mark -
#pragma mark ARView extension

@interface HOCARView ()
{
    mat4f_t projectionTransform;
    mat4f_t cameraTransform;
    vec4f_t *placesOfInterestCoordinates;

}
@property (nonatomic, strong) UIView *captureView;
@property (nonatomic, strong) AVCaptureDevice *camera;
@property (nonatomic, strong) AVCaptureSession *captureSession;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureLayer;

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, assign) double angle;
@property (nonatomic, assign) CLLocationDistance maxDistance;
@property (nonatomic, assign) CLLocationDistance minDistance;
@property (nonatomic, assign) BOOL firstTimeLocationUpdated;
@property (nonatomic, assign) BOOL running;
- (void)setup;

- (void)startCameraPreview;
- (void)stopCameraPreview;

- (void)startLocation;
- (void)stopLocation;

- (void)startDeviceMotion;
- (void)stopDeviceMotion;

- (void)startDisplayLink;
- (void)stopDisplayLink;

- (void)updatePlacesOfInterestCoordinates;

- (void)onDisplayLink:(id)sender;
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;

@end


@implementation HOCARView
#pragma mark - HOCARView implementation

#pragma mark init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.running = NO;
    self.firstTimeLocationUpdated = NO;
    
    [self addSubview:self.captureView];
    [self sendSubviewToBack:self.captureView];
    
    // Initialize projection matrix
    createProjectionMatrix(projectionTransform, 60.0f*DEGREES_TO_RADIANS, self.bounds.size.width*1.0f / self.bounds.size.height, 0.25f, 1000.0f);
    [self updateConstraints];
    [self setNeedsDisplay];
}

- (void) updateConstraints
{
    [super updateConstraints];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.captureView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.captureView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.captureView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.captureView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    self.captureLayer.frame = self.captureView.bounds;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    self.captureLayer.frame = self.captureView.bounds;
}


- (void) removeFromSuperview
{
    
    NSLog(@"dealloc ar view");
    if (self.running)
    {
        [self stop];
    }
    self.pois = nil;
    [self.captureView removeFromSuperview];
    
    if (placesOfInterestCoordinates != NULL)
    {
        free(placesOfInterestCoordinates);
    }
    [super removeFromSuperview];
}

- (void)dealloc
{
    NSLog(@"dealloc ar view");
//    if (placesOfInterestCoordinates != NULL)
//    {
//        free(placesOfInterestCoordinates);
//    }
//
}

#pragma  mark - public selectors
- (void)start
{
//    if (self.running)
//    {
//        NSLog(@"running return");
//        return;
//    }
    NSLog(@"Not running");
    self.running  = YES;
    createProjectionMatrix(projectionTransform, 60.0f*DEGREES_TO_RADIANS, self.bounds.size.width*1.0f / self.bounds.size.height, 0.25f, 100.0f);
    [self startCameraPreview];
    [self startLocation];
    self.location = self.locationManager.location;
    NSLog(@"Location manager: %@", self.location);
    [self startDeviceMotion];
    [self startDisplayLink];
    //NSLog(@"Current Location: %@", self.location);
}

- (void)stop
{
//    if (!self.running)
//    {
//        return;
//    }
    [self stopCameraPreview];
    [self stopLocation];
    [self stopDeviceMotion];
    [self stopDisplayLink];
    self.running = NO;
}

#pragma mark - public properties

- (CLLocation *) currentLocation
{
    return self.location;
}

- (void)setPois:(NSArray *)pois
{
    for (id<HOCARViewPoi> poi in [_pois objectEnumerator])
    {
        UIView *view = nil;
        if (self.datasource)
        {
           view = [self.datasource viewForPoiWithIdentifier:poi.arIdentifier];
        }
        [view removeFromSuperview];
    }
    
    _pois = pois;
    if (self.location != nil)
    {
        [self updatePlacesOfInterestCoordinates];
    }
}

#pragma mark - private properties
- (UIView *) captureView
{
    if (!_captureView)
    {
        _captureView = [[UIView alloc] init];
        _captureView.backgroundColor = [UIColor clearColor];
        _captureView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _captureView;
}

- (AVCaptureSession *) captureSession
{
    if (!_captureSession)
    {
        _captureSession = [[AVCaptureSession alloc] init];
        AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.camera error:nil];
        [_captureSession addInput:newVideoInput];
    }
    return _captureSession;
}

- (AVCaptureDevice *) camera
{
    if (!_camera)
    {
        _camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    return _camera;
}

- (AVCaptureVideoPreviewLayer *) captureLayer
{
    if (!_captureLayer)
    {
        _captureLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];


        //[_captureLayer setOrientation:AVCaptureVideoOrientationPortrait];
        [_captureLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];

    }
    return _captureLayer;
}

- (CLLocationManager *) locationManager
{
    if (!_locationManager)
    {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
    }
    return _locationManager;
}

- (CMMotionManager *) motionManager
{
    if (!_motionManager)
    {
        _motionManager = [[CMMotionManager alloc] init];
        // Tell CoreMotion to show the compass calibration HUD when required to provide true north-referenced attitude
        _motionManager.showsDeviceMovementDisplay = YES;
        _motionManager.deviceMotionUpdateInterval = 1.0 / 60.0;
        
    }
    return _motionManager;
}

- (CADisplayLink *) displayLink
{
    if (!_displayLink)
    {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onDisplayLink:)];
    }
    return _displayLink;
}

#pragma mark - private selectors
- (void)startCameraPreview
{
    if (self.camera == nil)
    {
        return;
    }
    
    [self.captureView.layer addSublayer:self.captureLayer];
    
    // Start the session. This is done asychronously since -startRunning doesn't return until the session is running.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.captureSession startRunning];
    });
}

- (void)stopCameraPreview
{
    [self.captureSession stopRunning];
    [self.captureLayer removeFromSuperlayer];
    self.captureSession = nil;
    self.captureLayer = nil;
    self.camera = nil;
}

- (void)startLocation
{

    //! TODO: Do the permission stuff here
    [self.locationManager startUpdatingLocation];
}

- (void)stopLocation
{
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
}

- (void)startDeviceMotion
{
    [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXTrueNorthZVertical];
}

- (void)stopDeviceMotion
{
    [self.motionManager stopDeviceMotionUpdates];
    self.motionManager = nil;
}

- (void)startDisplayLink
{
    [self.displayLink setFrameInterval:1];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)stopDisplayLink
{
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)updatePlacesOfInterestCoordinates
{
    
    if (placesOfInterestCoordinates != NULL) {
        free(placesOfInterestCoordinates);
    }
    placesOfInterestCoordinates = (vec4f_t *)malloc(sizeof(vec4f_t)*self.pois.count);
    
    int i = 0;
    
    double myX, myY, myZ;
    latLonToEcef(self.location.coordinate.latitude, self.location.coordinate.longitude, 0.0, &myX, &myY, &myZ);
    
    // Array of NSData instances, each of which contains a struct with the distance to a POI and the
    // POI's index into placesOfInterest
    // Will be used to ensure proper Z-ordering of UIViews
    typedef struct
    {
        float distance;
        int index;
    } DistanceAndIndex;
    NSMutableArray *orderedDistances = [NSMutableArray arrayWithCapacity:self.pois.count];
    
    // Compute the world coordinates of each place-of-interest
    for (id <HOCARViewPoi> poi in [self.pois objectEnumerator]) {
        double poiX, poiY, poiZ, e, n, u;
        
        latLonToEcef(poi.arLocation.coordinate.latitude, poi.arLocation.coordinate.longitude, 0.0, &poiX, &poiY, &poiZ);
        ecefToEnu(self.location.coordinate.latitude, self.location.coordinate.longitude, myX, myY, myZ, poiX, poiY, poiZ, &e, &n, &u);
        
        placesOfInterestCoordinates[i][0] = (float)n;
        placesOfInterestCoordinates[i][1]= -(float)e;
        placesOfInterestCoordinates[i][2] = 0.0f;
        placesOfInterestCoordinates[i][3] = 1.0f;
        
        // Add struct containing distance and index to orderedDistances
        DistanceAndIndex distanceAndIndex;
        distanceAndIndex.distance = sqrtf(n*n + e*e);
        distanceAndIndex.index = i;
        [orderedDistances insertObject:[NSData dataWithBytes:&distanceAndIndex length:sizeof(distanceAndIndex)] atIndex:i++];
    }
    
    
    
    // Sort orderedDistances in ascending order based on distance from the user
    [orderedDistances sortUsingComparator:(NSComparator)^(NSData *a, NSData *b)
    {
        const DistanceAndIndex *aData = (const DistanceAndIndex *)a.bytes;
        const DistanceAndIndex *bData = (const DistanceAndIndex *)b.bytes;
        if (aData->distance < bData->distance)
        {
            return NSOrderedAscending;
        }
        else if (aData->distance > bData->distance)
        {
            return NSOrderedDescending;
        }
        else
        {
            return NSOrderedSame;
        }
    }];
    DistanceAndIndex *distanceAndIndex;
    for (NSData *d in [orderedDistances reverseObjectEnumerator])
    {
        
        distanceAndIndex = (DistanceAndIndex *)d.bytes;
        int pos = distanceAndIndex->index;
        id <HOCARViewPoi> poi = (id <HOCARViewPoi> )[self.pois objectAtIndex:pos];
        if (poi.arMaxDistance > distanceAndIndex->distance)
        {
            //NSLog(@"%@ - %f %f", poi.arIdentifier, poi.arMaxDistance, distanceAndIndex->distance);
            self.maxDistance = distanceAndIndex->distance;
            break;
        }
    }
    for (NSData *d in orderedDistances)
    {
        distanceAndIndex = (DistanceAndIndex *)d.bytes;
        int pos = distanceAndIndex->index;
        id <HOCARViewPoi> poi = (id <HOCARViewPoi> )[self.pois objectAtIndex:pos];
        
        self.minDistance = distanceAndIndex->distance;
        if (poi.arMaxDistance > distanceAndIndex->distance)
        {
            self.minDistance = distanceAndIndex->distance;
            break;
        }
    }
    //NSLog(@"Max: %f", self.maxDistance);
    //NSLog(@"Min: %f", self.minDistance);
    // Add subviews in descending Z-order so they overlap properly
    for (NSData *d in [orderedDistances reverseObjectEnumerator])
    {
        const DistanceAndIndex *distanceAndIndex = (const DistanceAndIndex *)d.bytes;
        id <HOCARViewPoi> poi = (id <HOCARViewPoi> )[self.pois objectAtIndex:distanceAndIndex->index];
        if (self.datasource)
        {

            CLLocationDistance dist = [self.location distanceFromLocation:poi.arLocation];
            HOCPoiView *view = [self.datasource viewForPoiWithIdentifier:poi.arIdentifier];
            view.angle = self.angle;
            [view updateDistance:dist minDistance:self.minDistance maxDistance:self.maxDistance];
            [self addSubview:view];
        }
    }
}

- (void)onDisplayLink:(id)sender
{
    CMDeviceMotion *d = self.motionManager.deviceMotion;
    if (d != nil)
    {
        CMRotationMatrix r = d.attitude.rotationMatrix;
        transformFromCMRotationMatrix(cameraTransform, &r);
        self.angle = atan2(d.gravity.y, d.gravity.x) + M_PI_2;
       // NSLog(@"Attitude: %@", d.attitude.description);
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect
{
    if (placesOfInterestCoordinates == nil)
    {
        return;
    }
    
    mat4f_t projectionCameraTransform;
    multiplyMatrixAndMatrix(projectionCameraTransform, projectionTransform, cameraTransform);
    
    int i = 0;
    for (id <HOCARViewPoi> poi in [self.pois objectEnumerator])
    {
        vec4f_t v;
        multiplyMatrixAndVector(v, projectionCameraTransform, placesOfInterestCoordinates[i]);
        
        float x = (v[0] / v[3] + 1.0f) * 0.5f;
        float y = (v[1] / v[3] + 1.0f) * 0.5f;
        
        if (!isnan(x) && !isnan(y) && self.datasource)
        {
            CLLocationDistance dist = [self.location distanceFromLocation:poi.arLocation];
        
            HOCPoiView *view = [self.datasource viewForPoiWithIdentifier:poi.arIdentifier];
            
            BOOL visible = view.visible;
            if (visible && v[2] < 0.0f)
            {
                float distanceScale = view.zDistance;
                float y1 = self.bounds.size.height * distanceScale * 0.6f;
                float yPos = (0.8 * self.bounds.size.height) - y * self.bounds.size.height * 1.4 + y1;
//                NSLog(@"x: %f", x);
//                NSLog(@"y: %f", y);
//                NSLog(@"y1: %f", y1);
//
//                NSLog(@"size: %@", NSStringFromCGSize(self.bounds.size));
//                NSLog(@"yPos: %f", yPos);
                view.center = CGPointMake(x*self.bounds.size.width, yPos);
              //  NSLog(@"Dist: %f", dist);
                [view updateDistance:dist minDistance:self.minDistance maxDistance:self.maxDistance];
                view.angle = self.angle;
                view.hidden = NO;
                view.inView = YES;
            }
            else
            {
                view.hidden = YES;
                view.inView = NO;
            }
        }
        i++;
    }
    
}

- (void) setAngle:(double)angle
{
    _angle = angle;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    self.location = newLocation;
    if (self.pois != nil)
    {
        [self updatePlacesOfInterestCoordinates];
    }
}


@end

#pragma mark - Math utilities definition

// Creates a projection matrix using the given y-axis field-of-view, aspect ratio, and near and far clipping planes
void createProjectionMatrix(mat4f_t mout, float fovy, float aspect, float zNear, float zFar)
{
    float f = 1.0f / tanf(fovy/2.0f);
    
    mout[0] = f / aspect;
    mout[1] = 0.0f;
    mout[2] = 0.0f;
    mout[3] = 0.0f;
    
    mout[4] = 0.0f;
    mout[5] = f;
    mout[6] = 0.0f;
    mout[7] = 0.0f;
    
    mout[8] = 0.0f;
    mout[9] = 0.0f;
    mout[10] = (zFar+zNear) / (zNear-zFar);
    mout[11] = -1.0f;
    
    mout[12] = 0.0f;
    mout[13] = 0.0f;
    mout[14] = 2 * zFar * zNear /  (zNear-zFar);
    mout[15] = 0.0f;
}

// Matrix-vector and matrix-matricx multiplication routines
void multiplyMatrixAndVector(vec4f_t vout, const mat4f_t m, const vec4f_t v)
{
    vout[0] = m[0]*v[0] + m[4]*v[1] + m[8]*v[2] + m[12]*v[3];
    vout[1] = m[1]*v[0] + m[5]*v[1] + m[9]*v[2] + m[13]*v[3];
    vout[2] = m[2]*v[0] + m[6]*v[1] + m[10]*v[2] + m[14]*v[3];
    vout[3] = m[3]*v[0] + m[7]*v[1] + m[11]*v[2] + m[15]*v[3];
}

void multiplyMatrixAndMatrix(mat4f_t c, const mat4f_t a, const mat4f_t b)
{
    uint8_t col, row, i;
    memset(c, 0, 16*sizeof(float));
    
    for (col = 0; col < 4; col++) {
        for (row = 0; row < 4; row++) {
            for (i = 0; i < 4; i++) {
                c[col*4+row] += a[i*4+row]*b[col*4+i];
            }
        }
    }
}

// Initialize mout to be an affine transform corresponding to the same rotation specified by m
void transformFromCMRotationMatrix(vec4f_t mout, const CMRotationMatrix *m)
{
    mout[0] = (float)m->m11;
    mout[1] = (float)m->m21;
    mout[2] = (float)m->m31;
    mout[3] = 0.0f;
    
    mout[4] = (float)m->m12;
    mout[5] = (float)m->m22;
    mout[6] = (float)m->m32;
    mout[7] = 0.0f;
    
    mout[8] = (float)m->m13;
    mout[9] = (float)m->m23;
    mout[10] = (float)m->m33;
    mout[11] = 0.0f;
    
    mout[12] = 0.0f;
    mout[13] = 0.0f;
    mout[14] = 0.0f;
    mout[15] = 1.0f;
}

#pragma mark -Geodetic utilities definition

// References to ECEF and ECEF to ENU conversion may be found on the web.

// Converts latitude, longitude to ECEF coordinate system
void latLonToEcef(double lat, double lon, double alt, double *x, double *y, double *z)
{
    double clat = cos(lat * DEGREES_TO_RADIANS);
    double slat = sin(lat * DEGREES_TO_RADIANS);
    double clon = cos(lon * DEGREES_TO_RADIANS);
    double slon = sin(lon * DEGREES_TO_RADIANS);
    
    double N = WGS84_A / sqrt(1.0 - WGS84_E * WGS84_E * slat * slat);
    
    *x = (N + alt) * clat * clon;
    *y = (N + alt) * clat * slon;
    *z = (N * (1.0 - WGS84_E * WGS84_E) + alt) * slat;
}

// Coverts ECEF to ENU coordinates centered at given lat, lon
void ecefToEnu(double lat, double lon, double x, double y, double z, double xr, double yr, double zr, double *e, double *n, double *u)
{
    double clat = cos(lat * DEGREES_TO_RADIANS);
    double slat = sin(lat * DEGREES_TO_RADIANS);
    double clon = cos(lon * DEGREES_TO_RADIANS);
    double slon = sin(lon * DEGREES_TO_RADIANS);
    double dx = x - xr;
    double dy = y - yr;
    double dz = z - zr;
    
    *e = -slon*dx  + clon*dy;
    *n = -slat*clon*dx - slat*slon*dy + clat*dz;
    *u = clat*clon*dx + clat*slon*dy + slat*dz;
}

