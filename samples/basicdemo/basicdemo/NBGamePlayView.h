//
//  GamePlayView.h
//  basicdemo
//
//  Created by liu enbao on 25/10/2018.
//  Copyright © 2018 liu enbao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NBGamePlayView;

@protocol GLRendererDelegate<NSObject>

- (void)glRenderCreated:(NBGamePlayView*)view;

- (void)glRenderSizeChanged:(NBGamePlayView*)view width:(NSInteger)width height:(NSInteger)height;

- (void)glRenderDrawFrame:(NBGamePlayView*)view;

- (void)glRenderDestroy:(NBGamePlayView*)view;

@end

typedef void (^NBEventRunnable)();

@interface NBGamePlayView : UIView

@property (readonly, nonatomic, getter=getContext) EAGLContext* context;

@property (nonatomic, strong) id<GLRendererDelegate> renderer;

- (void)setSwapInterval:(NSInteger)interval;
- (NSInteger)swapInterval;

- (void)pause;
- (void)resume;

- (void)queueEvent:(nonnull NBEventRunnable)runnable;

@end
