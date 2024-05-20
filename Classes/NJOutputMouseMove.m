//
//  NJOutputMouseMove.m
//  Enjoy
//
//  Created by Yifeng Huang on 7/26/12.
//

#import "NJOutputMouseMove.h"

#import "NJInputController.h"

@implementation NJOutputMouseMove

+ (NSString *)serializationCode {
    return @"mouse move";
}

- (NSDictionary *)serialize {
    return @{ @"type": self.class.serializationCode,
              @"axis": @(_axis),
              @"speed": @(_speed),
              @"set" : @(_set)
              };
}

+ (NJOutput *)outputWithSerialization:(NSDictionary *)serialization {
    NJOutputMouseMove *output = [[NJOutputMouseMove alloc] init];
    output.axis = [serialization[@"axis"] intValue];
    output.speed = [serialization[@"speed"] floatValue];
    output.set = [serialization[@"set"] boolValue];
    if (output.speed == 0)
        output.speed = 10;
    return output;
}

- (BOOL)isContinuous {
    return YES;
}

static CGFloat pointRectSquaredDistance(NSPoint p, NSRect r) {
    CGFloat dx = p.x - MAX(MIN(p.x, r.origin.x + r.size.width), r.origin.x);
    CGFloat dy = p.y - MAX(MIN(p.y, r.origin.y + r.size.height), r.origin.y);
    return dx * dx + dy * dy;
}

#define CLAMP(a, l, h) MIN(h, MAX(a, l))

- (NSScreen*)screenContaining:(NSPoint)mouseLoc {
    for (NSScreen *screen in NSScreen.screens) {
        if (NSMouseInRect(mouseLoc, screen.frame, NO)) {
            return screen;
        }
    }

    return nil;
}


- (NSScreen*)nearestScreenTo:(NSPoint)mouseLoc {
    NSScreen *nearestScreen = nil;
    NSArray *screens = NSScreen.screens;
    CGFloat minDistance = 0;
    for (NSScreen *screen in screens) {
        CGFloat d = pointRectSquaredDistance(mouseLoc, screen.frame);
        if (minDistance == 0 || d < minDistance) {
            minDistance = d;
            nearestScreen = screen;
        }
    }
    return nearestScreen;
}

- (NSPoint)clampToScreen:(NSPoint)mouseLoc screen:(NSScreen*)screen {
    NSRect frame = screen.frame;
    mouseLoc.x = CLAMP(mouseLoc.x, NSMinX(frame), NSMaxX(frame) - 1);
    mouseLoc.y = CLAMP(mouseLoc.y, NSMinY(frame) + 1, NSMaxY(frame));
    return mouseLoc;
}


- (NSPoint)moveMouseFrom:(NSPoint)mouseLoc {
    CGFloat dx = 0, dy = 0;
    switch (_axis) {
        case 0:
            dx = -self.magnitude * _speed;
            break;
        case 1:
            dx = self.magnitude * _speed;
            break;
        case 2:
            dy = -self.magnitude * _speed;
            break;
        case 3:
            dy = self.magnitude * _speed;
            break;
    }

    mouseLoc.x = mouseLoc.x + dx;
    mouseLoc.y = mouseLoc.y - dy;
    NSScreen* screen = [self screenContaining:mouseLoc];
    if (!screen) {
        mouseLoc = [self clampToScreen:mouseLoc screen:[self nearestScreenTo:mouseLoc]];
    }

    return mouseLoc;
}


- (NSPoint)setMouseFrom:(NSPoint)mouseLoc {
    NSScreen* screen = [self screenContaining:mouseLoc];
    if (!screen) {
        screen = [self nearestScreenTo:mouseLoc];
    }

    NSRect frame = screen.frame;
    NSLog(@"%f", self.magnitude);

    switch (_axis) {
        case 0:
            mouseLoc.x = NSMidX(frame) - (NSWidth(frame) * self.magnitude * 0.5 * (self.speed / 20.f));
            break;
        case 1:
            mouseLoc.x = NSMidX(frame) + (NSWidth(frame) * self.magnitude * 0.5 * (self.speed / 20.f));
            break;
        case 2:
            mouseLoc.y = NSMidY(frame) - (NSHeight(frame) * self.magnitude * 0.5 * (self.speed / 20.f));
            break;
        case 3:
            mouseLoc.y = NSMidY(frame) + (NSHeight(frame) * self.magnitude * 0.5 * (self.speed / 20.f));
            break;
    }

    mouseLoc = [self clampToScreen:mouseLoc screen:screen];
    NSLog(@"%f,%f", mouseLoc.x, mouseLoc.y);

    return mouseLoc;
}


- (BOOL)update:(NJInputController *)ic {

    if (self.magnitude < 0.05) {
        if (self.inDeadZone) {
            return NO; // dead zone
        }
        self.inDeadZone = YES;
        self.magnitude = 0;
    } else {
        self.inDeadZone = NO;
    }

    NSPoint start = ic.mouseLoc;
    NSPoint mouseLoc;
    if (self.set) {
        mouseLoc = [self setMouseFrom:start];
    } else {
        mouseLoc = [self moveMouseFrom:start];
    }
    ic.mouseLoc = mouseLoc;

    CGFloat height = ((NSScreen *)[NSScreen.screens firstObject]).frame.size.height;
    CGEventRef move = CGEventCreateMouseEvent(NULL, kCGEventMouseMoved,
                                              CGPointMake(mouseLoc.x, height - mouseLoc.y),
                                              0);
    CGEventSetIntegerValueField(move, kCGMouseEventDeltaX, (int)(mouseLoc.x - start.x));
    CGEventSetIntegerValueField(move, kCGMouseEventDeltaY, (int)(mouseLoc.y - start.y));
    CGEventPost(kCGHIDEventTap, move);

    if (CGEventSourceButtonState(kCGEventSourceStateHIDSystemState, kCGMouseButtonLeft)) {
        CGEventSetType(move, kCGEventLeftMouseDragged);
        CGEventSetIntegerValueField(move, kCGMouseEventButtonNumber, kCGMouseButtonLeft);
        CGEventPost(kCGHIDEventTap, move);
    }
    if (CGEventSourceButtonState(kCGEventSourceStateHIDSystemState, kCGMouseButtonRight)) {
        CGEventSetType(move, kCGEventRightMouseDragged);
        CGEventSetIntegerValueField(move, kCGMouseEventButtonNumber, kCGMouseButtonRight);
        CGEventPost(kCGHIDEventTap, move);
    }
    if (CGEventSourceButtonState(kCGEventSourceStateHIDSystemState, kCGMouseButtonCenter)) {
        CGEventSetType(move, kCGEventOtherMouseDragged);
        CGEventSetIntegerValueField(move, kCGMouseEventButtonNumber, kCGMouseButtonCenter);
        CGEventPost(kCGHIDEventTap, move);
    }

    CFRelease(move);
    return YES;
}

@end
