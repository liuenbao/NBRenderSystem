//
//  ViewController.m
//  basicdemo
//
//  Created by liu enbao on 25/10/2018.
//  Copyright © 2018 liu enbao. All rights reserved.
//

#import "GamePlayViewController.h"
#import "GamePlayView.h"

#import <CoreMotion/CoreMotion.h>

#include "Base.h"
#include "Platform.h"
#include "FileSystem.h"
#include "Game.h"
#include "Form.h"
#include "ScriptController.h"

#define DeviceOrientedSize(o)         ((o == UIInterfaceOrientationPortrait || o == UIInterfaceOrientationPortraitUpsideDown)?                      \
                            CGSizeMake([[UIScreen mainScreen] bounds].size.width * [[UIScreen mainScreen] scale], [[UIScreen mainScreen] bounds].size.height * [[UIScreen mainScreen] scale]):  \
                            CGSizeMake([[UIScreen mainScreen] bounds].size.height * [[UIScreen mainScreen] scale], [[UIScreen mainScreen] bounds].size.width * [[UIScreen mainScreen] scale]))

static __weak GamePlayViewController* __viewController = NULL;
static GamePlayView* __view = NULL;

static double __timeAbsolute;
static bool __vsync = WINDOW_VSYNC;

double getMachTimeInMilliseconds();

@interface GamePlayViewController () {
    GamePlayView* _playView;
    gameplay::Platform* _platform;
//    CMMotionManager *motionManager;
}

@end

@implementation GamePlayViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
//        motionManager = [[CMMotionManager alloc] init];
//        if([motionManager isAccelerometerAvailable] == YES)
//        {
//            motionManager.accelerometerUpdateInterval = 1 / 40.0;    // 40Hz
//            [motionManager startAccelerometerUpdates];
//        }
//        if([motionManager isGyroAvailable] == YES)
//        {
//            motionManager.gyroUpdateInterval = 1 / 40.0;    // 40Hz
//            [motionManager startGyroUpdates];
//        }
        
        gameplay::Game* game = gameplay::Game::getInstance();
        _platform = gameplay::Platform::create(game);
        if (__viewController == nil) {
            __viewController = self;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View lifecycle
- (void)loadView
{
    self.view = [[GamePlayView alloc] init];
    if (__view == nil) {
        __view = (GamePlayView*)self.view;
    }
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    __view = nil;
    __viewController = nil;
}

- (void)getAccelerometerPitch:(float*)pitch roll:(float*)roll
{
//    float p = 0.0f;
//    float r = 0.0f;
//    CMAccelerometerData* accelerometerData = motionManager.accelerometerData;
//    if(accelerometerData != nil)
//    {
//        float tx, ty, tz;
//
//        switch ([[UIApplication sharedApplication] statusBarOrientation])
//        {
//            case UIInterfaceOrientationLandscapeRight:
//                tx = -accelerometerData.acceleration.y;
//                ty = accelerometerData.acceleration.x;
//                break;
//
//            case UIInterfaceOrientationLandscapeLeft:
//                tx = accelerometerData.acceleration.y;
//                ty = -accelerometerData.acceleration.x;
//                break;
//
//            case UIInterfaceOrientationPortraitUpsideDown:
//                tx = -accelerometerData.acceleration.y;
//                ty = -accelerometerData.acceleration.x;
//                break;
//
//            case UIInterfaceOrientationPortrait:
//                tx = accelerometerData.acceleration.x;
//                ty = accelerometerData.acceleration.y;
//                break;
//        }
//        tz = accelerometerData.acceleration.z;
//
//        p = atan(ty / sqrt(tx * tx + tz * tz)) * 180.0f * M_1_PI;
//        r = atan(tx / sqrt(ty * ty + tz * tz)) * 180.0f * M_1_PI;
//    }
//
//    if(pitch != NULL)
//        *pitch = p;
//    if(roll != NULL)
//        *roll = r;
}

- (void)getRawAccelX:(float*)x Y:(float*)y Z:(float*)z
{
//    CMAccelerometerData* accelerometerData = motionManager.accelerometerData;
//    if(accelerometerData != nil)
//    {
//        *x = -9.81f * accelerometerData.acceleration.x;
//        *y = -9.81f * accelerometerData.acceleration.y;
//        *z = -9.81f * accelerometerData.acceleration.z;
//    }
}

- (void)getRawGyroX:(float*)x Y:(float*)y Z:(float*)z
{
//    CMGyroData* gyroData = motionManager.gyroData;
//    if(gyroData != nil)
//    {
//        *x = gyroData.rotationRate.x;
//        *y = gyroData.rotationRate.y;
//        *z = gyroData.rotationRate.z;
//    }
}

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
        [__view stopUpdating];
        exit(0);
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
        __timeAbsolute = getMachTimeInMilliseconds();
        return __timeAbsolute;
    }
    
    void Platform::setAbsoluteTime(double time)
    {
        __timeAbsolute = time;
    }
    
    bool Platform::isVsync()
    {
        return __vsync;
    }
    
    void Platform::setVsync(bool enable)
    {
        __vsync = enable;
    }
    
    void Platform::swapBuffers()
    {
        if (__view)
            [__view swapBuffers];
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
        __view.multipleTouchEnabled = enabled;
    }
    
    bool Platform::isMultiTouch()
    {
        return __view.multipleTouchEnabled;
    }
    
    void Platform::displayKeyboard(bool display)
    {
        if(__view)
        {
            if(display)
            {
                [__view showKeyboard];
            }
            else
            {
                [__view dismissKeyboard];
            }
        }
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
        [__view registerGesture:evt];
    }
    
    void Platform::unregisterGesture(Gesture::GestureEvent evt)
    {
        [__view unregisterGesture:evt];
    }
    
    bool Platform::isGestureRegistered(Gesture::GestureEvent evt)
    {
        return [__view isGestureRegistered:evt];
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
