//
//  NSApplication+LoginItem.m
//  Enjoyable
//
//  Created by Joe Wreschnig on 3/13/13.
//
//

#import "NSRunningApplication+LoginItem.h"
#import <CoreServices/CoreServices.h>
#import <ServiceManagement/ServiceManagement.h>
#import <Cocoa/Cocoa.h>
#include <libproc.h> // For proc_pidinfo

//static const UInt32 RESOLVE_FLAGS = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;

@implementation NSRunningApplication (LoginItem)

- (BOOL)isLoginItem {
    NSString *myBundleIdentifier = self.bundleIdentifier; // Assuming you have a property for the bundle identifier

    // Check if the login item is enabled
    BOOL isEnabled = SMLoginItemSetEnabled((__bridge CFStringRef)myBundleIdentifier, true);
    
    // Check for any other logic if needed, currently just returning the status
    return isEnabled;
}

- (void)addToLoginItems {
    if (!self.isLoginItem) {
        // Get the bundle identifier
        NSString *myBundleIdentifier = self.bundleIdentifier; // Assuming this returns the correct bundle identifier

        // Enable the login item
        BOOL success = SMLoginItemSetEnabled((__bridge CFStringRef)myBundleIdentifier, true);
        if (success) {
            NSLog(@"Successfully added to login items.");
        } else {
            NSLog(@"Failed to add to login items.");
        }
    }
}

- (void)removeFromLoginItems {
    NSString *myBundleIdentifier = self.bundleIdentifier; // Assuming this returns the correct bundle identifier

    // Disable the login item
    BOOL success = SMLoginItemSetEnabled((__bridge CFStringRef)myBundleIdentifier, false);
    if (success) {
        NSLog(@"Successfully removed from login items.");
    } else {
        NSLog(@"Failed to remove from login items.");
    }
}

- (BOOL)wasLaunchedAsLoginItemOrResume {
    // Get the current process's identifier
    pid_t currentProcessID = [[NSProcessInfo processInfo] processIdentifier];

    // Allocate space for process info
    struct proc_bsdinfo procInfo;
    memset(&procInfo, 0, sizeof(procInfo)); // Zero out the structure

    // Get the process information
    if (proc_pidinfo(currentProcessID, PROC_PIDLISTFDS, 0, &procInfo, sizeof(procInfo)) > 0) {
        pid_t parentProcessID = procInfo.pbi_ppid; // Get the parent process ID

        // Get the parent application
        NSRunningApplication *parentApp = [NSRunningApplication runningApplicationWithProcessIdentifier:parentProcessID];

        // Check if the parent application is valid
        if (parentApp) {
            // Check the bundle identifier of the parent application
            NSString *parentBundleIdentifier = parentApp.bundleIdentifier;
            return [parentBundleIdentifier isEqualToString:@"your.bundle.identifier"]; // Replace with your app's bundle identifier
        }
    }

    return NO; // Handle case where parent app could not be found
}
@end
