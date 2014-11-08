WatchDog-iOS
=============

Implement a simple configurable watchdog in iOS. This watchdog can run continuously during the lifetime of an application, or run only once on demand for a certain part of code execution.

INSTALLATION
-------------
To install, just add all these .h/m files into your project.

USAGE
-----
WatchDog *dog = [[WatchDog alloc] initWithTimeout:2];

//run watchdog continuously for entire application

[dog monitorContinuously];	// call it when application starts

//application execution, which could include long-running tasks. If any task runs longer than watchdog timeout, WATCHDOG warning message will be logged.

[dog cancelMonitorContinuously];	//call it when application stops


//run watchdog only once for a part of code

[dog monitorOnce];	// call it before the code segment you want to monitor

//some code segment which could run longer than watchdog timeout

[dog cancelMonitorOnce];	//call it after the code segment
