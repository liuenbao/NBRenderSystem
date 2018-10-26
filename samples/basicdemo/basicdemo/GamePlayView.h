//
//  GamePlayView.h
//  basicdemo
//
//  Created by liu enbao on 25/10/2018.
//  Copyright © 2018 liu enbao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GamePlayView;

@protocol GLRenderDelegate<NSObject>

- (void)glRenderCreated:(GamePlayView*)view;

- (void)glRenderSizeChanged:(GamePlayView*)view width:(NSInteger)width height:(NSInteger)height;

- (void)glRenderDrawFrame:(GamePlayView*)view;

- (void)glRenderDestroy:(GamePlayView*)view;

@end

@interface GamePlayView : UIView

@property (readonly, nonatomic, getter=isUpdating) BOOL updating;
@property (readonly, nonatomic, getter=getContext) EAGLContext* context;

@property (nonatomic, weak) id<GLRenderDelegate> renderDelegate;

- (void)startUpdating;
- (void)stopUpdating;

- (void)setSwapInterval:(NSInteger)interval;
- (int)swapInterval;

@end
