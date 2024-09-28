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

static const UInt32 RESOLVE_FLAGS = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;

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
    // Get the current process's information
    ProcessSerialNumber psn = {0, kCurrentProcess};
    NSDictionary *processInfo = CFBridgingRelease(ProcessInformationCopyDictionary(&psn, kProcessDictionaryIncludeAllInformationMask));

    // Handle error if processInfo couldn't be obtained
    if (!processInfo) {
        return NO;
    }

    long long parent = [processInfo[@"ParentPSN"] longLongValue];
    ProcessSerialNumber parentPsn = {
        (parent >> 32) & 0xFFFFFFFF,
        parent & 0xFFFFFFFF
    };

    // Use NSWorkspace to get the parent process information
    NSRunningApplication *parentApp = [NSRunningApplication runningApplicationWithProcessIdentifier:parentPsn.highLongOfPSN];

    // Check if parentApp is valid
    if (parentApp) {
        // Access the bundle identifier instead of file creator
        NSString *parentBundleIdentifier = parentApp.bundleIdentifier;
        return [parentBundleIdentifier isEqualToString:@"your.bundle.identifier"]; // Replace with your app's bundle identifier
    }

    return NO; // Handle case where parent app could not be found
}
@end
