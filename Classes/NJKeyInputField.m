#import "NJKeyInputField.h"
#include <Carbon/Carbon.h>

enum {
    kVK_RightCommandUnique = kVK_Command - 1, // Renamed to avoid conflict
    kVK_Insert = 0x72,
    kVK_Power = 0x7f,
    kVK_ApplicationMenu = 0x6e,
    kVK_MAX = 0xFFFF,
};

const CGKeyCode NJKeyInputFieldEmpty = kVK_MAX;

@interface NJKeyInputField () <NSTextFieldDelegate>
@end

@implementation NJKeyInputField {
    NSTextField *field;
    NSImageView *warning;
}

- (id)initWithFrame:(NSRect)frameRect {
    if ((self = [super initWithFrame:frameRect])) {
        field = [[NSTextField alloc] initWithFrame:self.bounds];
        field.alignment = NSTextAlignmentCenter; // Updated
        field.editable = NO;
        field.selectable = NO;
        field.delegate = self;
        [self addSubview:field];

        warning = [[NSImageView alloc] init];
        warning.image = [NSImage imageNamed:@"NSInvalidDataFreestanding"];
        CGSize imgSize = warning.image.size;
        CGRect bounds = self.bounds;
        warning.frame = CGRectMake(bounds.size.width - (imgSize.width + 4),
                                   (bounds.size.height - imgSize.height) / 2,
                                   imgSize.width, imgSize.height);

        warning.toolTip = NSLocalizedString(@"invalid key code", @"shown when the user types an invalid key code");
        warning.hidden = YES;
        [self addSubview:warning];
    }
    return self;
}

- (void)clear {
    self.keyCode = NJKeyInputFieldEmpty;
    [self.delegate keyInputFieldDidClear:self];
    [self resignFirstResponder];  // Corrected method call
}

- (BOOL)hasKeyCode {
    return self.keyCode != NJKeyInputFieldEmpty;
}

+ (NSString *)displayNameForKeyCode:(CGKeyCode)keyCode {
    switch (keyCode) {
        case kVK_Command: return NSLocalizedString(@"Left ⌘", @"keyboard key");
        case kVK_RightCommandUnique: return NSLocalizedString(@"Right ⌘", @"keyboard key"); // Updated
        // (Other cases continue...)
        default:
            return [[NSString alloc] initWithFormat:NSLocalizedString(@"key 0x%x", @"unknown key code"), keyCode];
    }
}

- (BOOL)acceptsFirstResponder {
    return self.isEnabled;
}

- (BOOL)becomeFirstResponder {
    field.backgroundColor = NSColor.selectedTextBackgroundColor;
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    field.backgroundColor = NSColor.textBackgroundColor;
    return [super resignFirstResponder];
}

- (void)setKeyCode:(CGKeyCode)keyCode {
    _keyCode = keyCode;
    field.stringValue = [NJKeyInputField displayNameForKeyCode:keyCode];
}

- (void)keyDown:(NSEvent *)event {
    static const NSUInteger IGNORE = NSEventModifierFlagOption | NSEventModifierFlagCommand; // Updated
    if (!event.isARepeat) {
        if ((event.modifierFlags & IGNORE) && event.keyCode == kVK_Delete) {
            // Allow Alt/Command+Delete to clear the field.
            self.keyCode = NJKeyInputFieldEmpty;
            [self.delegate keyInputFieldDidClear:self];
        } else if (!(event.modifierFlags & IGNORE)) {
            self.keyCode = event.keyCode;
            [self.delegate keyInputField:self didChangeKey:self.keyCode];
        }
        [self resignFirstResponder]; // Corrected method call
    }
}

// Other methods remain unchanged...

@end
