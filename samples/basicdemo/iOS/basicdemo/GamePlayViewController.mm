//
//  ViewController.m
//  basicdemo
//
//  Created by liu enbao on 25/10/2018.
//  Copyright © 2018 liu enbao. All rights reserved.
//

#import "GamePlayViewController.h"
#import "GamePlayView.h"
#import "NBGLView.h"

#import <CoreMotion/CoreMotion.h>

#include "Base.h"
#include "Platform.h"
#include "FileSystem.h"
#include "Game.h"
#include "Form.h"
#include "ScriptController.h"
#include <unistd.h>
#include <sys/time.h>
#import <mach/mach_time.h>

#include "SamplesGame.h"

#define DeviceOrientedSize(o)         ((o == UIInterfaceOrientationPortrait || o == UIInterfaceOrientationPortraitUpsideDown)?                      \
                            CGSizeMake([[UIScreen mainScreen] bounds].size.width * [[UIScreen mainScreen] scale], [[UIScreen mainScreen] bounds].size.height * [[UIScreen mainScreen] scale]):  \
                            CGSizeMake([[UIScreen mainScreen] bounds].size.height * [[UIScreen mainScreen] scale], [[UIScreen mainScreen] bounds].size.width * [[UIScreen mainScreen] scale]))

extern const int WINDOW_SCALE = [[UIScreen mainScreen] scale];

class TouchPoint
{
public:
    unsigned int hashId;
    int x;
    int y;
    bool down;
    
    TouchPoint()
    {
        hashId = 0;
        x = 0;
        y = 0;
        down = false;
    }
};

// gestures

#define GESTURE_LONG_PRESS_DURATION_MIN 0.2
#define GESTURE_LONG_PRESS_DISTANCE_MIN 10

// more than we'd ever need, to be safe
#define TOUCH_POINTS_MAX (10)

double getMachTimeInMilliseconds();

int getKey(unichar keyCode);
int getUnicode(int key);

static __weak GamePlayViewController* __viewController = NULL;

double getMachTimeInMilliseconds();

@interface GamePlayViewController () <NBGLRenderer> {
    gameplay::Platform* _platform;
    gameplay::Game* _game;
    CMMotionManager *motionManager;
    
    UITapGestureRecognizer *_tapRecognizer;
    UIPinchGestureRecognizer *_pinchRecognizer;
    UISwipeGestureRecognizer *_swipeRecognizer;
    UILongPressGestureRecognizer *_longPressRecognizer;
    UILongPressGestureRecognizer *_longTapRecognizer;
    UILongPressGestureRecognizer *_dragAndDropRecognizer;
    
    BOOL updating;
    
    TouchPoint touchPoints[TOUCH_POINTS_MAX];
    bool gestureDraging;
    long gestureLongTapStartTimestamp;
    CGPoint gestureLongPressStartPosition;
}

@property (nonatomic, strong) NBGLView* playView;
@property (nonatomic, assign) bool vsync;
@property (nonatomic, assign) double timeAbsolute;

@end

@implementation GamePlayViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        motionManager = [[CMMotionManager alloc] init];
        if([motionManager isAccelerometerAvailable] == YES)
        {
            motionManager.accelerometerUpdateInterval = 1 / 40.0;    // 40Hz
            [motionManager startAccelerometerUpdates];
        }
        if([motionManager isGyroAvailable] == YES)
        {
            motionManager.gyroUpdateInterval = 1 / 40.0;    // 40Hz
            [motionManager startGyroUpdates];
        }
        
        _game = new SamplesGame();
        _platform = gameplay::Platform::create(_game);
        if (__viewController == nil) {
            __viewController = self;
        }
        
        updating = NO;
        _vsync = WINDOW_VSYNC;
        gestureDraging = false;
        gestureLongTapStartTimestamp = 0;
        
        // Set the resource path and initalize the game
        NSString* bundlePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/"];
        gameplay::FileSystem::setResourcePath([bundlePath fileSystemRepresentation]);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:)
                                                     name:UIApplicationWillTerminateNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {

}

- (void)viewWillDisappear:(BOOL)animated {

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View lifecycle
- (void)loadView
{
    self.view = self.playView = [[NBGLView alloc] init];
    [self.playView setRenderer:self];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    __viewController = nil;
    
    if (_game != NULL) {
        delete _game;
        _game = NULL;
    }
}

- (BOOL)canBecomeFirstResponder
{
    // Override so we can control the keyboard
    return YES;
}

- (void)getAccelerometerPitch:(float*)pitch roll:(float*)roll
{
    float p = 0.0f;
    float r = 0.0f;
    CMAccelerometerData* accelerometerData = motionManager.accelerometerData;
    if(accelerometerData != nil)
    {
        float tx, ty, tz;

        switch ([[UIApplication sharedApplication] statusBarOrientation])
        {
            case UIInterfaceOrientationLandscapeRight:
                tx = -accelerometerData.acceleration.y;
                ty = accelerometerData.acceleration.x;
                break;

            case UIInterfaceOrientationLandscapeLeft:
                tx = accelerometerData.acceleration.y;
                ty = -accelerometerData.acceleration.x;
                break;

            case UIInterfaceOrientationPortraitUpsideDown:
                tx = -accelerometerData.acceleration.y;
                ty = -accelerometerData.acceleration.x;
                break;

            case UIInterfaceOrientationPortrait:
                tx = accelerometerData.acceleration.x;
                ty = accelerometerData.acceleration.y;
                break;
        }
        tz = accelerometerData.acceleration.z;

        p = atan(ty / sqrt(tx * tx + tz * tz)) * 180.0f * M_1_PI;
        r = atan(tx / sqrt(ty * ty + tz * tz)) * 180.0f * M_1_PI;
    }

    if(pitch != NULL)
        *pitch = p;
    if(roll != NULL)
        *roll = r;
}

- (void)getRawAccelX:(float*)x Y:(float*)y Z:(float*)z
{
    CMAccelerometerData* accelerometerData = motionManager.accelerometerData;
    if(accelerometerData != nil)
    {
        *x = -9.81f * accelerometerData.acceleration.x;
        *y = -9.81f * accelerometerData.acceleration.y;
        *z = -9.81f * accelerometerData.acceleration.z;
    }
}

- (void)getRawGyroX:(float*)x Y:(float*)y Z:(float*)z
{
    CMGyroData* gyroData = motionManager.gyroData;
    if(gyroData != nil)
    {
        *x = gyroData.rotationRate.x;
        *y = gyroData.rotationRate.y;
        *z = gyroData.rotationRate.z;
    }
}

#pragma render delegate begin

- (void)glRenderCreated:(GamePlayView*)view {
    _game->run();
}

- (void)glRenderSizeChanged:(GamePlayView*)view width:(NSInteger)width height:(NSInteger)height {
    _game->setViewport(gameplay::Rectangle(0, 0, width, height));
}

- (void)glRenderDrawFrame:(GamePlayView*)view {
    _game->frame();
}

- (void)glRenderDestroy:(GamePlayView*)view {
    if (_game->canExit())
        _game->exit();
}

#pragma render delegate end

- (BOOL)showKeyboard
{
    return [self becomeFirstResponder];
}

- (BOOL)dismissKeyboard
{
    return [self resignFirstResponder];
}

- (void)insertText:(NSString*)text
{
    if([text length] == 0) return;
    assert([text length] == 1);
    unichar c = [text characterAtIndex:0];
    int key = getKey(c);
    gameplay::Platform::keyEventInternal(gameplay::Keyboard::KEY_PRESS, key);
    
    int character = getUnicode(key);
    if (character)
    {
        gameplay::Platform::keyEventInternal(gameplay::Keyboard::KEY_CHAR, /*character*/c);
    }
    
    gameplay::Platform::keyEventInternal(gameplay::Keyboard::KEY_RELEASE, key);
}

- (void)deleteBackward
{
    gameplay::Platform::keyEventInternal(gameplay::Keyboard::KEY_PRESS, gameplay::Keyboard::KEY_BACKSPACE);
    gameplay::Platform::keyEventInternal(gameplay::Keyboard::KEY_CHAR, getUnicode(gameplay::Keyboard::KEY_BACKSPACE));
    gameplay::Platform::keyEventInternal(gameplay::Keyboard::KEY_RELEASE, gameplay::Keyboard::KEY_BACKSPACE);
}

- (BOOL)hasText
{
    return YES;
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    unsigned int touchID = 0;
    for(UITouch* touch in touches)
    {
        CGPoint touchPoint = [touch locationInView:self.view];
        if(self.view.multipleTouchEnabled == YES)
        {
            touchID = [touch hash];
        }
        
        // Nested loop efficiency shouldn't be a concern since both loop sizes are small (<= 10)
        int i = 0;
        while (i < TOUCH_POINTS_MAX && touchPoints[i].down)
        {
            i++;
        }
        
        if (i < TOUCH_POINTS_MAX)
        {
            touchPoints[i].hashId = touchID;
            touchPoints[i].x = touchPoint.x * WINDOW_SCALE;
            touchPoints[i].y = touchPoint.y * WINDOW_SCALE;
            touchPoints[i].down = true;
            
            gameplay::Platform::touchEventInternal(gameplay::Touch::TOUCH_PRESS, touchPoints[i].x, touchPoints[i].y, i);
        }
        else
        {
            printf("touchesBegan: unable to find free element in __touchPoints\n");
        }
    }
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    unsigned int touchID = 0;
    for(UITouch* touch in touches)
    {
        CGPoint touchPoint = [touch locationInView:self.view];
        if(self.view.multipleTouchEnabled == YES)
            touchID = [touch hash];
        
        // Nested loop efficiency shouldn't be a concern since both loop sizes are small (<= 10)
        bool found = false;
        for (int i = 0; !found && i < TOUCH_POINTS_MAX; i++)
        {
            if (touchPoints[i].down && touchPoints[i].hashId == touchID)
            {
                touchPoints[i].down = false;
                gameplay::Platform::touchEventInternal(gameplay::Touch::TOUCH_RELEASE, touchPoint.x * WINDOW_SCALE, touchPoint.y * WINDOW_SCALE, i);
                found = true;
            }
        }
        
        if (!found)
        {
            // It seems possible to receive an ID not in the array.
            // The best we can do is clear the whole array.
            for (int i = 0; i < TOUCH_POINTS_MAX; i++)
            {
                if (touchPoints[i].down)
                {
                    touchPoints[i].down = false;
                    gameplay::Platform::touchEventInternal(gameplay::Touch::TOUCH_RELEASE, touchPoints[i].x, touchPoints[i].y, i);
                }
            }
        }
    }
}

- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event
{
    // No equivalent for this in GamePlay -- treat as touch end
    [self touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    unsigned int touchID = 0;
    for(UITouch* touch in touches)
    {
        CGPoint touchPoint = [touch locationInView:self.view];
        if(self.view.multipleTouchEnabled == YES)
            touchID = [touch hash];
        
        // Nested loop efficiency shouldn't be a concern since both loop sizes are small (<= 10)
        for (int i = 0; i < TOUCH_POINTS_MAX; i++)
        {
            if (touchPoints[i].down && touchPoints[i].hashId == touchID)
            {
                touchPoints[i].x = touchPoint.x * WINDOW_SCALE;
                touchPoints[i].y = touchPoint.y * WINDOW_SCALE;
                gameplay::Platform::touchEventInternal(gameplay::Touch::TOUCH_MOVE, touchPoints[i].x, touchPoints[i].y, i);
                break;
            }
        }
    }
}

// Gesture support for Mac OS X Trackpads
- (bool)isGestureRegistered: (gameplay::Gesture::GestureEvent) evt
{
    switch(evt) {
        case gameplay::Gesture::GESTURE_SWIPE:
            return (_swipeRecognizer != NULL);
        case gameplay::Gesture::GESTURE_PINCH:
            return (_pinchRecognizer != NULL);
        case gameplay::Gesture::GESTURE_TAP:
            return (_tapRecognizer != NULL);
        case gameplay::Gesture::GESTURE_LONG_TAP:
            return (_longTapRecognizer != NULL);
        case gameplay::Gesture::GESTURE_DRAG:
        case gameplay::Gesture::GESTURE_DROP:
            return (_dragAndDropRecognizer != NULL);
        default:
            break;
    }
    return false;
}

- (void)registerGesture: (gameplay::Gesture::GestureEvent) evt
{
    if((evt & gameplay::Gesture::GESTURE_SWIPE) == gameplay::Gesture::GESTURE_SWIPE && _swipeRecognizer == NULL)
    {
        // right swipe (default)
        _swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
        [self.view addGestureRecognizer:_swipeRecognizer];
        
        // left swipe
        UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
        swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.view addGestureRecognizer:swipeGesture];
        
        // up swipe
        UISwipeGestureRecognizer *swipeGesture2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
        swipeGesture2.direction = UISwipeGestureRecognizerDirectionUp;
        [self.view addGestureRecognizer:swipeGesture2];
        
        // down swipe
        UISwipeGestureRecognizer *swipeGesture3 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
        swipeGesture3.direction = UISwipeGestureRecognizerDirectionDown;
        [self.view addGestureRecognizer:swipeGesture3];
    }
    if((evt & gameplay::Gesture::GESTURE_PINCH) == gameplay::Gesture::GESTURE_PINCH && _pinchRecognizer == NULL)
    {
        _pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
        [self.view addGestureRecognizer:_pinchRecognizer];
    }
    if((evt & gameplay::Gesture::GESTURE_TAP) == gameplay::Gesture::GESTURE_TAP && _tapRecognizer == NULL)
    {
        _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [self.view addGestureRecognizer:_tapRecognizer];
    }
    if ((evt & gameplay::Gesture::GESTURE_LONG_TAP) == gameplay::Gesture::GESTURE_LONG_TAP && _longTapRecognizer == NULL)
    {
        if (_longPressRecognizer == NULL)
        {
            _longPressRecognizer =[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
            _longPressRecognizer.minimumPressDuration = GESTURE_LONG_PRESS_DURATION_MIN;
            _longPressRecognizer.allowableMovement = CGFLOAT_MAX;
            [self.view addGestureRecognizer:_longPressRecognizer];
        }
        _longTapRecognizer = _longPressRecognizer;
    }
    if (((evt & gameplay::Gesture::GESTURE_DRAG) == gameplay::Gesture::GESTURE_DRAG || (evt & gameplay::Gesture::GESTURE_DROP) == gameplay::Gesture::GESTURE_DROP) && _dragAndDropRecognizer == NULL)
    {
        if (_longPressRecognizer == NULL)
        {
            _longPressRecognizer =[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
            _longPressRecognizer.minimumPressDuration = GESTURE_LONG_PRESS_DURATION_MIN;
            _longPressRecognizer.allowableMovement = CGFLOAT_MAX;
            [self.view addGestureRecognizer:_longPressRecognizer];
        }
        _dragAndDropRecognizer = _longPressRecognizer;
    }
}

- (void)unregisterGesture: (gameplay::Gesture::GestureEvent) evt
{
    if((evt & gameplay::Gesture::GESTURE_SWIPE) == gameplay::Gesture::GESTURE_SWIPE && _swipeRecognizer != NULL)
    {
        [self.view removeGestureRecognizer:_swipeRecognizer];
        _swipeRecognizer = NULL;
    }
    if((evt & gameplay::Gesture::GESTURE_PINCH) == gameplay::Gesture::GESTURE_PINCH && _pinchRecognizer != NULL)
    {
        [self.view removeGestureRecognizer:_pinchRecognizer];
        _pinchRecognizer = NULL;
    }
    if((evt & gameplay::Gesture::GESTURE_TAP) == gameplay::Gesture::GESTURE_TAP && _tapRecognizer != NULL)
    {
        [self.view removeGestureRecognizer:_tapRecognizer];
        _tapRecognizer = NULL;
    }
    if((evt & gameplay::Gesture::GESTURE_LONG_TAP) == gameplay::Gesture::GESTURE_LONG_TAP && _longTapRecognizer != NULL)
    {
        if (_longTapRecognizer == NULL)
        {
            [self.view removeGestureRecognizer:_longTapRecognizer];
        }
        _longTapRecognizer = NULL;
    }
    if (((evt & gameplay::Gesture::GESTURE_DRAG) == gameplay::Gesture::GESTURE_DRAG || (evt & gameplay::Gesture::GESTURE_DROP) == gameplay::Gesture::GESTURE_DROP) && _dragAndDropRecognizer != NULL)
    {
        if (_dragAndDropRecognizer == NULL)
        {
            [self.view removeGestureRecognizer:_dragAndDropRecognizer];
        }
        _dragAndDropRecognizer = NULL;
    }
}

- (void)handleTapGesture:(UITapGestureRecognizer*)sender
{
    CGPoint location = [sender locationInView:self.view];
    gameplay::Platform::gestureTapEventInternal(location.x * WINDOW_SCALE, location.y * WINDOW_SCALE);
}

- (void)handleLongTapGesture:(UILongPressGestureRecognizer*)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        struct timeval time;
        
        gettimeofday(&time, NULL);
        gestureLongTapStartTimestamp = (time.tv_sec * 1000) + (time.tv_usec / 1000);
    }
    else if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint location = [sender locationInView:self.view];
        struct timeval time;
        long currentTimeStamp;
        
        gettimeofday(&time, NULL);
        currentTimeStamp = (time.tv_sec * 1000) + (time.tv_usec / 1000);
        gameplay::Platform::gestureLongTapEventInternal(location.x * WINDOW_SCALE, location.y * WINDOW_SCALE, currentTimeStamp - gestureLongTapStartTimestamp);
    }
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer*)sender
{
    CGFloat factor = [sender scale];
    CGPoint location = [sender locationInView:self.view];
    gameplay::Platform::gesturePinchEventInternal(location.x * WINDOW_SCALE, location.y * WINDOW_SCALE, factor);
}

- (void)handleSwipeGesture:(UISwipeGestureRecognizer*)sender
{
    UISwipeGestureRecognizerDirection direction = [sender direction];
    CGPoint location = [sender locationInView:self.view];
    int gameplayDirection = 0;
    switch(direction) {
        case UISwipeGestureRecognizerDirectionRight:
            gameplayDirection = gameplay::Gesture::SWIPE_DIRECTION_RIGHT;
            break;
        case UISwipeGestureRecognizerDirectionLeft:
            gameplayDirection = gameplay::Gesture::SWIPE_DIRECTION_LEFT;
            break;
        case UISwipeGestureRecognizerDirectionUp:
            gameplayDirection = gameplay::Gesture::SWIPE_DIRECTION_UP;
            break;
        case UISwipeGestureRecognizerDirectionDown:
            gameplayDirection = gameplay::Gesture::SWIPE_DIRECTION_DOWN;
            break;
    }
    gameplay::Platform::gestureSwipeEventInternal(location.x * WINDOW_SCALE, location.y * WINDOW_SCALE, gameplayDirection);
}

- (void)handleLongPressGestures:(UILongPressGestureRecognizer*)sender
{
    CGPoint location = [sender locationInView:self.view];
    
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        struct timeval time;
        
        gettimeofday(&time, NULL);
        gestureLongTapStartTimestamp = (time.tv_sec * 1000) + (time.tv_usec / 1000);
        gestureLongPressStartPosition = location;
    }
    if (sender.state == UIGestureRecognizerStateChanged)
    {
        if (gestureDraging)
            gameplay::Platform::gestureDragEventInternal(location.x * WINDOW_SCALE, location.y * WINDOW_SCALE);
        else
        {
            float delta = sqrt(pow(gestureLongPressStartPosition.x - location.x, 2) + pow(gestureLongPressStartPosition.y - location.y, 2));
            
            if (delta >= GESTURE_LONG_PRESS_DISTANCE_MIN)
            {
                gestureDraging = true;
                gameplay::Platform::gestureDragEventInternal(gestureLongPressStartPosition.x * WINDOW_SCALE, gestureLongPressStartPosition.y * WINDOW_SCALE);
            }
        }
    }
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        if (gestureDraging)
        {
            gameplay::Platform::gestureDropEventInternal(location.x * WINDOW_SCALE, location.y * WINDOW_SCALE);
            gestureDraging = false;
        }
        else
        {
            struct timeval time;
            long currentTimeStamp;
            
            gettimeofday(&time, NULL);
            currentTimeStamp = (time.tv_sec * 1000) + (time.tv_usec / 1000);
            gameplay::Platform::gestureLongTapEventInternal(location.x * WINDOW_SCALE, location.y * WINDOW_SCALE, currentTimeStamp - gestureLongTapStartTimestamp);
        }
    }
    if ((sender.state == UIGestureRecognizerStateCancelled || sender.state == UIGestureRecognizerStateFailed) && gestureDraging)
    {
        gameplay::Platform::gestureDropEventInternal(location.x * WINDOW_SCALE, location.y * WINDOW_SCALE);
        gestureDraging = false;
    }
}

- (void)startUpdating
{
    if (!updating)
    {
        if (_game)
            _game->resume();
        updating = TRUE;
        [_playView resume];
    }
}

- (void)stopUpdating
{
    if (updating)
    {
        [_playView pause];
        
        if (_game)
            _game->pause();
        updating = FALSE;
    }
}

#pragma application lifecycle begin

- (void)applicationWillResignActive:(NSNotification *)notification {
    [self stopUpdating];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [self startUpdating];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    [self stopUpdating];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    [self startUpdating];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [self stopUpdating];
}

#pragma application lifecycle end

@end

double getMachTimeInMilliseconds()
{
    static const double kOneMillion = 1000 * 1000;
    static mach_timebase_info_data_t s_timebase_info;
    
    if (s_timebase_info.denom == 0)
        (void) mach_timebase_info(&s_timebase_info);
    
    // mach_absolute_time() returns billionth of seconds, so divide by one million to get milliseconds
    GP_ASSERT(s_timebase_info.denom);
    return ((double)mach_absolute_time() * (double)s_timebase_info.numer) / (kOneMillion * (double)s_timebase_info.denom);
}

namespace gameplay
{
    extern void print(const char* format, ...)
    {
        GP_ASSERT(format);
        va_list argptr;
        va_start(argptr, format);
        vfprintf(stderr, format, argptr);
        va_end(argptr);
    }
    
    extern int strcmpnocase(const char* s1, const char* s2)
    {
        return strcasecmp(s1, s2);
    }
    
    Platform::Platform(Game* game) : _game(game)
    {
    }
    
    Platform::~Platform()
    {
    }
    
    Platform* Platform::create(Game* game)
    {
        Platform* platform = new Platform(game);
        return platform;
    }
    
    int Platform::enterMessagePump()
    {
//        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
//        [AppDelegate load];
//        UIApplicationMain(0, nil, NSStringFromClass([AppDelegate class]), NSStringFromClass([AppDelegate class]));
//        [pool release];
        return EXIT_SUCCESS;
    }
    
    void Platform::signalShutdown()
    {
        // Cannot 'exit' an iOS Application
        assert(false);
//        [__view stopUpdating];
//        exit(0);
    }
    
    bool Platform::canExit()
    {
        return false;
    }
    
    unsigned int Platform::getDisplayWidth()
    {
#ifdef NSFoundationVersionNumber_iOS_7_1
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)
        {
            //iOS 8+
            return [[UIScreen mainScreen] bounds].size.width * [[UIScreen mainScreen] scale];
        }
        else
#endif
        {
            CGSize size = DeviceOrientedSize([__viewController interfaceOrientation]);
            return size.width;
        }
    }
    
    unsigned int Platform::getDisplayHeight()
    {
#ifdef NSFoundationVersionNumber_iOS_7_1
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)
        {
            //iOS 8+
            return [[UIScreen mainScreen] bounds].size.height * [[UIScreen mainScreen] scale];
        }
        else
#endif
        {
            CGSize size = DeviceOrientedSize([__viewController interfaceOrientation]);
            return size.height;
        }
    }
    
    double Platform::getAbsoluteTime()
    {
        __viewController.timeAbsolute = getMachTimeInMilliseconds();
        return __viewController.timeAbsolute;
    }
    
    void Platform::setAbsoluteTime(double time)
    {
        __viewController.timeAbsolute = time;
    }
    
    bool Platform::isVsync()
    {
        return __viewController.vsync;
    }
    
    void Platform::setVsync(bool enable)
    {
        __viewController.vsync = enable;
    }
    
    void Platform::swapBuffers()
    {
//        // not supported in current moment
//        if (__viewController.playView)
//            [__viewController.playView swapBuffers];
    }

    void Platform::sleep(long ms)
    {
        usleep(ms * 1000);
    }
    
    bool Platform::hasAccelerometer()
    {
        return true;
    }
    
    void Platform::getAccelerometerValues(float* pitch, float* roll)
    {
        [__viewController getAccelerometerPitch:pitch roll:roll];
    }
    
    void Platform::getSensorValues(float* accelX, float* accelY, float* accelZ, float* gyroX, float* gyroY, float* gyroZ)
    {
        float x, y, z;
        [__viewController getRawAccelX:&x Y:&y Z:&z];
        if (accelX)
        {
            *accelX = x;
        }
        if (accelY)
        {
            *accelY = y;
        }
        if (accelZ)
        {
            *accelZ = z;
        }
        
        [__viewController getRawGyroX:&x Y:&y Z:&z];
        if (gyroX)
        {
            *gyroX = x;
        }
        if (gyroY)
        {
            *gyroY = y;
        }
        if (gyroZ)
        {
            *gyroZ = z;
        }
    }
    
    void Platform::getArguments(int* argc, char*** argv)
    {
//        if (argc)
//            *argc = __argc;
//        if (argv)
//            *argv = __argv;
    }
    
    bool Platform::hasMouse()
    {
        // not supported
        return false;
    }
    
    void Platform::setMouseCaptured(bool captured)
    {
        // not supported
    }
    
    bool Platform::isMouseCaptured()
    {
        // not supported
        return false;
    }
    
    void Platform::setCursorVisible(bool visible)
    {
        // not supported
    }
    
    bool Platform::isCursorVisible()
    {
        // not supported
        return false;
    }
    
    void Platform::setMultiSampling(bool enabled)
    {
        //todo
    }
    
    bool Platform::isMultiSampling()
    {
        return false; //todo
    }
    
    void Platform::setMultiTouch(bool enabled)
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
            __viewController.playView.multipleTouchEnabled = enabled;
        });
    }
    
    bool Platform::isMultiTouch()
    {
        __block bool isEnabled = false;
        dispatch_sync(dispatch_get_main_queue(), ^{
            isEnabled = __viewController.playView.multipleTouchEnabled;
        });
        return isEnabled;
    }
    
    void Platform::displayKeyboard(bool display)
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
            if(__viewController)
            {
                if(display)
                {
                    [__viewController showKeyboard];
                }
                else
                {
                    [__viewController dismissKeyboard];
                }
            }
        });
    }
    
    void Platform::shutdownInternal()
    {
        Game::getInstance()->shutdown();
    }
    
    bool Platform::isGestureSupported(Gesture::GestureEvent evt)
    {
        return true;
    }
    
    void Platform::registerGesture(Gesture::GestureEvent evt)
    {
        [__viewController registerGesture:evt];
    }
    
    void Platform::unregisterGesture(Gesture::GestureEvent evt)
    {
        [__viewController unregisterGesture:evt];
    }
    
    bool Platform::isGestureRegistered(Gesture::GestureEvent evt)
    {
        return [__viewController isGestureRegistered:evt];
    }
    
#ifdef MODULE_GUI_ENABLED
    void Platform::pollGamepadState(Gamepad* gamepad)
    {
    }
#endif // #ifdef MODULE_GUI_ENABLED
    
    bool Platform::launchURL(const char *url)
    {
        if (url == NULL || *url == '\0')
            return false;
        
        return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithUTF8String: url]]];
    }
    
    std::string Platform::displayFileDialog(size_t mode, const char* title, const char* filterDescription, const char* filterExtensions, const char* initialDirectory)
    {
        return "";
    }
    
}

int getKey(unichar keyCode)
{
    switch(keyCode)
    {
        case 0x0A:
            return gameplay::Keyboard::KEY_RETURN;
        case 0x20:
            return gameplay::Keyboard::KEY_SPACE;
            
        case 0x30:
            return gameplay::Keyboard::KEY_ZERO;
        case 0x31:
            return gameplay::Keyboard::KEY_ONE;
        case 0x32:
            return gameplay::Keyboard::KEY_TWO;
        case 0x33:
            return gameplay::Keyboard::KEY_THREE;
        case 0x34:
            return gameplay::Keyboard::KEY_FOUR;
        case 0x35:
            return gameplay::Keyboard::KEY_FIVE;
        case 0x36:
            return gameplay::Keyboard::KEY_SIX;
        case 0x37:
            return gameplay::Keyboard::KEY_SEVEN;
        case 0x38:
            return gameplay::Keyboard::KEY_EIGHT;
        case 0x39:
            return gameplay::Keyboard::KEY_NINE;
            
        case 0x41:
            return gameplay::Keyboard::KEY_CAPITAL_A;
        case 0x42:
            return gameplay::Keyboard::KEY_CAPITAL_B;
        case 0x43:
            return gameplay::Keyboard::KEY_CAPITAL_C;
        case 0x44:
            return gameplay::Keyboard::KEY_CAPITAL_D;
        case 0x45:
            return gameplay::Keyboard::KEY_CAPITAL_E;
        case 0x46:
            return gameplay::Keyboard::KEY_CAPITAL_F;
        case 0x47:
            return gameplay::Keyboard::KEY_CAPITAL_G;
        case 0x48:
            return gameplay::Keyboard::KEY_CAPITAL_H;
        case 0x49:
            return gameplay::Keyboard::KEY_CAPITAL_I;
        case 0x4A:
            return gameplay::Keyboard::KEY_CAPITAL_J;
        case 0x4B:
            return gameplay::Keyboard::KEY_CAPITAL_K;
        case 0x4C:
            return gameplay::Keyboard::KEY_CAPITAL_L;
        case 0x4D:
            return gameplay::Keyboard::KEY_CAPITAL_M;
        case 0x4E:
            return gameplay::Keyboard::KEY_CAPITAL_N;
        case 0x4F:
            return gameplay::Keyboard::KEY_CAPITAL_O;
        case 0x50:
            return gameplay::Keyboard::KEY_CAPITAL_P;
        case 0x51:
            return gameplay::Keyboard::KEY_CAPITAL_Q;
        case 0x52:
            return gameplay::Keyboard::KEY_CAPITAL_R;
        case 0x53:
            return gameplay::Keyboard::KEY_CAPITAL_S;
        case 0x54:
            return gameplay::Keyboard::KEY_CAPITAL_T;
        case 0x55:
            return gameplay::Keyboard::KEY_CAPITAL_U;
        case 0x56:
            return gameplay::Keyboard::KEY_CAPITAL_V;
        case 0x57:
            return gameplay::Keyboard::KEY_CAPITAL_W;
        case 0x58:
            return gameplay::Keyboard::KEY_CAPITAL_X;
        case 0x59:
            return gameplay::Keyboard::KEY_CAPITAL_Y;
        case 0x5A:
            return gameplay::Keyboard::KEY_CAPITAL_Z;
            
            
        case 0x61:
            return gameplay::Keyboard::KEY_A;
        case 0x62:
            return gameplay::Keyboard::KEY_B;
        case 0x63:
            return gameplay::Keyboard::KEY_C;
        case 0x64:
            return gameplay::Keyboard::KEY_D;
        case 0x65:
            return gameplay::Keyboard::KEY_E;
        case 0x66:
            return gameplay::Keyboard::KEY_F;
        case 0x67:
            return gameplay::Keyboard::KEY_G;
        case 0x68:
            return gameplay::Keyboard::KEY_H;
        case 0x69:
            return gameplay::Keyboard::KEY_I;
        case 0x6A:
            return gameplay::Keyboard::KEY_J;
        case 0x6B:
            return gameplay::Keyboard::KEY_K;
        case 0x6C:
            return gameplay::Keyboard::KEY_L;
        case 0x6D:
            return gameplay::Keyboard::KEY_M;
        case 0x6E:
            return gameplay::Keyboard::KEY_N;
        case 0x6F:
            return gameplay::Keyboard::KEY_O;
        case 0x70:
            return gameplay::Keyboard::KEY_P;
        case 0x71:
            return gameplay::Keyboard::KEY_Q;
        case 0x72:
            return gameplay::Keyboard::KEY_R;
        case 0x73:
            return gameplay::Keyboard::KEY_S;
        case 0x74:
            return gameplay::Keyboard::KEY_T;
        case 0x75:
            return gameplay::Keyboard::KEY_U;
        case 0x76:
            return gameplay::Keyboard::KEY_V;
        case 0x77:
            return gameplay::Keyboard::KEY_W;
        case 0x78:
            return gameplay::Keyboard::KEY_X;
        case 0x79:
            return gameplay::Keyboard::KEY_Y;
        case 0x7A:
            return gameplay::Keyboard::KEY_Z;
        default:
            break;
            
            // Symbol Row 3
        case 0x2E:
            return gameplay::Keyboard::KEY_PERIOD;
        case 0x2C:
            return gameplay::Keyboard::KEY_COMMA;
        case 0x3F:
            return gameplay::Keyboard::KEY_QUESTION;
        case 0x21:
            return gameplay::Keyboard::KEY_EXCLAM;
        case 0x27:
            return gameplay::Keyboard::KEY_APOSTROPHE;
            
            // Symbols Row 2
        case 0x2D:
            return gameplay::Keyboard::KEY_MINUS;
        case 0x2F:
            return gameplay::Keyboard::KEY_SLASH;
        case 0x3A:
            return gameplay::Keyboard::KEY_COLON;
        case 0x3B:
            return gameplay::Keyboard::KEY_SEMICOLON;
        case 0x28:
            return gameplay::Keyboard::KEY_LEFT_PARENTHESIS;
        case 0x29:
            return gameplay::Keyboard::KEY_RIGHT_PARENTHESIS;
        case 0x24:
            return gameplay::Keyboard::KEY_DOLLAR;
        case 0x26:
            return gameplay::Keyboard::KEY_AMPERSAND;
        case 0x40:
            return gameplay::Keyboard::KEY_AT;
        case 0x22:
            return gameplay::Keyboard::KEY_QUOTE;
            
            // Numeric Symbols Row 1
        case 0x5B:
            return gameplay::Keyboard::KEY_LEFT_BRACKET;
        case 0x5D:
            return gameplay::Keyboard::KEY_RIGHT_BRACKET;
        case 0x7B:
            return gameplay::Keyboard::KEY_LEFT_BRACE;
        case 0x7D:
            return gameplay::Keyboard::KEY_RIGHT_BRACE;
        case 0x23:
            return gameplay::Keyboard::KEY_NUMBER;
        case 0x25:
            return gameplay::Keyboard::KEY_PERCENT;
        case 0x5E:
            return gameplay::Keyboard::KEY_CIRCUMFLEX;
        case 0x2A:
            return gameplay::Keyboard::KEY_ASTERISK;
        case 0x2B:
            return gameplay::Keyboard::KEY_PLUS;
        case 0x3D:
            return gameplay::Keyboard::KEY_EQUAL;
            
            // Numeric Symbols Row 2
        case 0x5F:
            return gameplay::Keyboard::KEY_UNDERSCORE;
        case 0x5C:
            return gameplay::Keyboard::KEY_BACK_SLASH;
        case 0x7C:
            return gameplay::Keyboard::KEY_BAR;
        case 0x7E:
            return gameplay::Keyboard::KEY_TILDE;
        case 0x3C:
            return gameplay::Keyboard::KEY_LESS_THAN;
        case 0x3E:
            return gameplay::Keyboard::KEY_GREATER_THAN;
        case 0x80:
            return gameplay::Keyboard::KEY_EURO;
        case 0xA3:
            return gameplay::Keyboard::KEY_POUND;
        case 0xA5:
            return gameplay::Keyboard::KEY_YEN;
        case 0xB7:
            return gameplay::Keyboard::KEY_MIDDLE_DOT;
    }
    return gameplay::Keyboard::KEY_NONE;
}

/**
 * Returns the unicode value for the given keycode or zero if the key is not a valid printable character.
 */
int getUnicode(int key)
{
    
    switch (key)
    {
        case gameplay::Keyboard::KEY_BACKSPACE:
            return 0x0008;
        case gameplay::Keyboard::KEY_TAB:
            return 0x0009;
        case gameplay::Keyboard::KEY_RETURN:
        case gameplay::Keyboard::KEY_KP_ENTER:
            return 0x000A;
        case gameplay::Keyboard::KEY_ESCAPE:
            return 0x001B;
        case gameplay::Keyboard::KEY_SPACE:
        case gameplay::Keyboard::KEY_EXCLAM:
        case gameplay::Keyboard::KEY_QUOTE:
        case gameplay::Keyboard::KEY_NUMBER:
        case gameplay::Keyboard::KEY_DOLLAR:
        case gameplay::Keyboard::KEY_PERCENT:
        case gameplay::Keyboard::KEY_CIRCUMFLEX:
        case gameplay::Keyboard::KEY_AMPERSAND:
        case gameplay::Keyboard::KEY_APOSTROPHE:
        case gameplay::Keyboard::KEY_LEFT_PARENTHESIS:
        case gameplay::Keyboard::KEY_RIGHT_PARENTHESIS:
        case gameplay::Keyboard::KEY_ASTERISK:
        case gameplay::Keyboard::KEY_PLUS:
        case gameplay::Keyboard::KEY_COMMA:
        case gameplay::Keyboard::KEY_MINUS:
        case gameplay::Keyboard::KEY_PERIOD:
        case gameplay::Keyboard::KEY_SLASH:
        case gameplay::Keyboard::KEY_ZERO:
        case gameplay::Keyboard::KEY_ONE:
        case gameplay::Keyboard::KEY_TWO:
        case gameplay::Keyboard::KEY_THREE:
        case gameplay::Keyboard::KEY_FOUR:
        case gameplay::Keyboard::KEY_FIVE:
        case gameplay::Keyboard::KEY_SIX:
        case gameplay::Keyboard::KEY_SEVEN:
        case gameplay::Keyboard::KEY_EIGHT:
        case gameplay::Keyboard::KEY_NINE:
        case gameplay::Keyboard::KEY_COLON:
        case gameplay::Keyboard::KEY_SEMICOLON:
        case gameplay::Keyboard::KEY_LESS_THAN:
        case gameplay::Keyboard::KEY_EQUAL:
        case gameplay::Keyboard::KEY_GREATER_THAN:
        case gameplay::Keyboard::KEY_QUESTION:
        case gameplay::Keyboard::KEY_AT:
        case gameplay::Keyboard::KEY_CAPITAL_A:
        case gameplay::Keyboard::KEY_CAPITAL_B:
        case gameplay::Keyboard::KEY_CAPITAL_C:
        case gameplay::Keyboard::KEY_CAPITAL_D:
        case gameplay::Keyboard::KEY_CAPITAL_E:
        case gameplay::Keyboard::KEY_CAPITAL_F:
        case gameplay::Keyboard::KEY_CAPITAL_G:
        case gameplay::Keyboard::KEY_CAPITAL_H:
        case gameplay::Keyboard::KEY_CAPITAL_I:
        case gameplay::Keyboard::KEY_CAPITAL_J:
        case gameplay::Keyboard::KEY_CAPITAL_K:
        case gameplay::Keyboard::KEY_CAPITAL_L:
        case gameplay::Keyboard::KEY_CAPITAL_M:
        case gameplay::Keyboard::KEY_CAPITAL_N:
        case gameplay::Keyboard::KEY_CAPITAL_O:
        case gameplay::Keyboard::KEY_CAPITAL_P:
        case gameplay::Keyboard::KEY_CAPITAL_Q:
        case gameplay::Keyboard::KEY_CAPITAL_R:
        case gameplay::Keyboard::KEY_CAPITAL_S:
        case gameplay::Keyboard::KEY_CAPITAL_T:
        case gameplay::Keyboard::KEY_CAPITAL_U:
        case gameplay::Keyboard::KEY_CAPITAL_V:
        case gameplay::Keyboard::KEY_CAPITAL_W:
        case gameplay::Keyboard::KEY_CAPITAL_X:
        case gameplay::Keyboard::KEY_CAPITAL_Y:
        case gameplay::Keyboard::KEY_CAPITAL_Z:
        case gameplay::Keyboard::KEY_LEFT_BRACKET:
        case gameplay::Keyboard::KEY_BACK_SLASH:
        case gameplay::Keyboard::KEY_RIGHT_BRACKET:
        case gameplay::Keyboard::KEY_UNDERSCORE:
        case gameplay::Keyboard::KEY_GRAVE:
        case gameplay::Keyboard::KEY_A:
        case gameplay::Keyboard::KEY_B:
        case gameplay::Keyboard::KEY_C:
        case gameplay::Keyboard::KEY_D:
        case gameplay::Keyboard::KEY_E:
        case gameplay::Keyboard::KEY_F:
        case gameplay::Keyboard::KEY_G:
        case gameplay::Keyboard::KEY_H:
        case gameplay::Keyboard::KEY_I:
        case gameplay::Keyboard::KEY_J:
        case gameplay::Keyboard::KEY_K:
        case gameplay::Keyboard::KEY_L:
        case gameplay::Keyboard::KEY_M:
        case gameplay::Keyboard::KEY_N:
        case gameplay::Keyboard::KEY_O:
        case gameplay::Keyboard::KEY_P:
        case gameplay::Keyboard::KEY_Q:
        case gameplay::Keyboard::KEY_R:
        case gameplay::Keyboard::KEY_S:
        case gameplay::Keyboard::KEY_T:
        case gameplay::Keyboard::KEY_U:
        case gameplay::Keyboard::KEY_V:
        case gameplay::Keyboard::KEY_W:
        case gameplay::Keyboard::KEY_X:
        case gameplay::Keyboard::KEY_Y:
        case gameplay::Keyboard::KEY_Z:
        case gameplay::Keyboard::KEY_LEFT_BRACE:
        case gameplay::Keyboard::KEY_BAR:
        case gameplay::Keyboard::KEY_RIGHT_BRACE:
        case gameplay::Keyboard::KEY_TILDE:
            return key;
        default:
            return 0;
    }
}
