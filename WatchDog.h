//
//  WatchDog.h
//
//  Copyright (c) Ming Guo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WatchDog : NSObject

/**
 * Initialize with default timeout of 5 seconds
 */
-(instancetype)init;

/**
 * Initialize
 * @param timeout watchdog allowed timeout in seconds
 */
-(instancetype)initWithTimeout:(int)timeout;

/**
 * watchdog continuously monitors until explicitly stop
 * it is same as monitorContinuously2 but less efficient
 */
-(void)monitorContinuously;

/**
 * watchdog continuously monitors until explicitly stop
 * it is same as monitorContinuousy but more efficient
 */
-(void)monitorContinuously2;

/**
 * stop continuous watchdog monitor
 */
-(void)cancelMonitorContinuously;

/**
 * watchdog runs only once, it is normally used to measure/monitor one part of code execution
 * it is same as monitorOnce2 but with different implementation
 */
-(void)monitorOnce;

-(void)cancelMonitorOnce;

/**
 * watchdog runs only once, it is normally used to measure/monitor one part of code execution
 * it is same as monitorOnce but with different implementation
 */
-(void)monitorOnce2;

-(void)cancelMonitorOnce2;

@end
