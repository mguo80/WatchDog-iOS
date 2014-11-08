//
//  WatchDog.m
//
//  Copyright (c) Ming Guo. All rights reserved.
//

#import "WatchDog.h"

@interface WatchDog()
@property (nonatomic, strong) dispatch_queue_t monitorQueue;
@property (atomic)  int timeout;            //second
@property (atomic)  BOOL isContinuous;
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, strong) NSTimer *nsTimer;
@end

@implementation WatchDog

-(instancetype)init {
    return [self initWithTimeout:5];
}

-(instancetype)initWithTimeout:(int)timeout {
    if (self = [super init]) {
        self.timeout = timeout;
        self.monitorQueue = dispatch_queue_create("watchDogSerialQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

-(void)monitorContinuously {
    self.isContinuous = YES;
    dispatch_async(self.monitorQueue, ^{
        __block int ping = 0;
        while (self.isContinuous) {
            ping++;
            
            //push following block to main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                ping--;
            });
            
            [NSThread sleepForTimeInterval:self.timeout];
            
            if (ping > 0) {
                NSLog(@"WATCHDOG: task took longer than %d seconds", self.timeout);
            }
        }
    });
}

-(void)monitorContinuously2 {
    self.isContinuous = YES;
    dispatch_semaphore_t mutex = dispatch_semaphore_create(0);
    dispatch_async(self.monitorQueue, ^{
        __block int ping = 0;
        while (self.isContinuous) {
            ping++;
            
            //push following block to main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                ping--;
                dispatch_semaphore_signal(mutex);
            });
            
            dispatch_semaphore_wait(mutex, dispatch_time(DISPATCH_TIME_NOW, self.timeout * NSEC_PER_SEC));
            
            if (ping > 0) {
                NSLog(@"WATCHDOG: task took longer than %d seconds", self.timeout);
            }
        }
    });
}

-(void)cancelMonitorContinuously {
    self.isContinuous = NO;
}

-(void)monitorOnce {
    //schedule timer on background thread
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(self.timer, dispatch_time(DISPATCH_TIME_NOW, self.timeout * NSEC_PER_SEC), DISPATCH_TIME_FOREVER, 0);
    dispatch_source_set_event_handler(self.timer, ^{
        NSLog(@"WATCHDOG: task took longer than %d seconds", self.timeout);
        dispatch_source_cancel(self.timer);
    });
    dispatch_resume(self.timer);
}

-(void)cancelMonitorOnce {
    dispatch_source_cancel(self.timer);
}

-(void)monitorOnce2 {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        //add a timer into background thread runloop
        self.nsTimer = [NSTimer timerWithTimeInterval:self.timeout target:self selector:@selector(timeFired) userInfo:nil repeats:NO];
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addTimer:self.nsTimer forMode:NSRunLoopCommonModes];
        [runLoop run];
    });
}

-(void)timeFired {
    NSLog(@"WATCHDOG: task took longer than %d seconds", self.timeout);
}

-(void)cancelMonitorOnce2 {
    [self.nsTimer invalidate];
    self.nsTimer = nil;
}

@end
