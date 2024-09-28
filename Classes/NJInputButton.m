//
//  NJInputButton.m
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//

#import "NJInputButton.h"

// #define TraceValue NSLog
#define TraceValue(...) do {} while(0)

@implementation NJInputButton {
    CFIndex _min;
    CFIndex _max;
}

- (id)initWithElement:(IOHIDElementRef)element
                index:(int)index
               parent:(NJInputPathElement *)parent
{
    if ((self = [super initWithName:NJINPUT_NAME(NSLocalizedString(@"button %d", @"button name"), index)
                                eid:NJINPUT_EID("Button", index)
                            element:element
                             parent:parent])) {
        _min = IOHIDElementGetLogicalMin(element);
        _max = IOHIDElementGetLogicalMax(element);
    }
    return self;
}

- (id)findSubInputForValue:(IOHIDValueRef)val {
    TraceValue(@"%ld", IOHIDValueGetIntegerValue(val));
    return (IOHIDValueGetIntegerValue(val) != _min) ? self : nil;
}

- (void)notifyEvent:(IOHIDValueRef)valueRef {
    CFIndex value = IOHIDValueGetIntegerValue(valueRef);
    self.active = value != _min;
    self.magnitude = value / (float)_max;
    TraceValue(@"%ld %d %f", value, self.active, self.magnitude);
}

@end
