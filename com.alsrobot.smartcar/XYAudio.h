//
//  XYAudio.h
//  XYCoreBlueToothDemo
//
//  Created by RainPoll on 15/12/31.
//  Copyright © 2015年 RainPoll. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface XYAudio : NSObject

@property (assign ,nonatomic)CGFloat volume;
@property (strong ,nonatomic)NSURL *fileURL;
@property (assign ,nonatomic,getter=isEnable)BOOL enable;

+(instancetype)shareXYAudion;
+(instancetype)xyAudioWith:(NSURL *)fileURL;

+(void)addMusicFileURL:(NSURL *)fileURL;
+(void)playMusicAtIndex:(NSInteger)index;
+(void)stopMusicAtIndex:(NSInteger)index;
//设置播放次数
+(void)setMusicPlayTime:(NSInteger)times AtIndex:(NSInteger)index;

-(void)addMusicFileURL:(NSURL *)fileURL;
-(void)playMusicAtIndex:(NSInteger)index;
-(void)stopMusicAtIndex:(NSInteger)index;
-(void)replayMusicAtIndex:(NSInteger)index;
-(void)setMusicPlayTime:(NSInteger)times AtIndex:(NSInteger)index;

@end
