//
//  NJInputAnalog.m
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//

#import "NJInputAnalog.h"

static float normalize(CFIndex p, CFIndex min, CFIndex max) {
    return 2 * (p - min) / (float)(max - min) - 1;
}

@implementation NJInputAnalog {
    CFIndex _rawMin;
    CFIndex _rawMax;
    float _deadZone;
}

- (id)initWithElement:(IOHIDElementRef)element
                index:(int)index
               parent:(NJInputPathElement *)parent
{
    if ((self = [super initWithName:NJINPUT_NAME(NSLocalizedString(@"axis %d", @"axis name"), index)
                                eid:NJINPUT_EID("Axis", index)
                            element:element
                             parent:parent])) {
        self.children = @[[[NJInput alloc] initWithName:NSLocalizedString(@"axis low", @"axis low trigger")
                                                    eid:@"Low"
                                                   parent:self],
                          [[NJInput alloc] initWithName:NSLocalizedString(@"axis high", @"axis high trigger")
                                                    eid:@"High"
                                                   parent:self]];
        _rawMax = IOHIDElementGetPhysicalMax(element);
        _rawMin = IOHIDElementGetPhysicalMin(element);
        _deadZone = 0.25f; // (1.0f / (float) (_rawMax - _rawMin)) * 10.0f;
    }
    return self;
}

- (id)findSubInputForValue:(IOHIDValueRef)value {
    float mag = normalize(IOHIDValueGetIntegerValue(value), _rawMin, _rawMax);
    if (mag < -_deadZone)
        return self.children[0];
    else if (mag > _deadZone)
        return self.children[1];
    else
        return nil;
}

- (void)notifyEvent:(IOHIDValueRef)value {
    float magnitude = self.magnitude = normalize(IOHIDValueGetIntegerValue(value), _rawMin, _rawMax);
    if (fabsf(magnitude) < _deadZone) {
        magnitude = self.magnitude = 0;
    }

    [self.children[0] setMagnitude:fabsf(MIN(magnitude, 0))];
    [self.children[1] setMagnitude:fabsf(MAX(magnitude, 0))];
    [self.children[0] setActive:magnitude < -_deadZone];
    [self.children[1] setActive:magnitude > _deadZone];
}

@end
