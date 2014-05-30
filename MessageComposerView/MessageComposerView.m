// MessageComposerView.m
//
// Copyright (c) 2013 oseparovic. ( http://thegameengine.org )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MessageComposerView.h"

@interface MessageComposerView()
@property(nonatomic, strong) IBOutlet UITextView *messageTextView;
@property(nonatomic, strong) IBOutlet UIButton *sendButton;
@end

@implementation MessageComposerView

const int kComposerBackgroundTopPadding = 10;
const int kComposerBackgroundRightPadding = 10;
const int kComposerBackgroundBottomPadding = 10;
const int kComposerBackgroundLeftPadding = 10;
const int kComposerTextViewButtonBetweenPadding = 10;

// Default animation time for 5 <= iOS <= 7. Should be overwritten by first keyboard notification.
float keyboardAnimationDuration = 0.25;
int keyboardAnimationCurve = 7;
int keyboardOffset;

- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame andKeyboardOffset:0];
}

- (id)initWithFrame:(CGRect)frame andKeyboardOffset:(int)offset {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        keyboardOffset = offset;
        
        // alloc necessary elements
        self.sendButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.sendButton addTarget:self action:@selector(sendClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.messageTextView = [[UITextView alloc] initWithFrame:CGRectZero];
        
        // configure elements
        [self setup];
        
        // insert elements above MessageComposerView
        [self insertSubview:self.sendButton aboveSubview:self];
        [self insertSubview:self.messageTextView aboveSubview:self];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (void)dealloc {
    [self removeNotifications];
}

- (void)setup {
    self.backgroundColor = [UIColor lightGrayColor];
    self.autoresizesSubviews = YES;
    self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.userInteractionEnabled = YES;
    self.multipleTouchEnabled = NO;
    
    CGRect sendButtonFrame = self.bounds;
    sendButtonFrame.size.width = 50;
    sendButtonFrame.size.height = 34;
    sendButtonFrame.origin.x = self.frame.size.width - kComposerBackgroundRightPadding - sendButtonFrame.size.width;
    sendButtonFrame.origin.y = kComposerBackgroundRightPadding;
    self.sendButton.frame = sendButtonFrame;
    self.sendButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    self.sendButton.layer.cornerRadius = 5;
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    [self.sendButton setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [self.sendButton setBackgroundColor:[UIColor orangeColor]];
    [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
    self.sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    
    CGRect messageTextViewFrame = self.bounds;
    messageTextViewFrame.origin.x = kComposerBackgroundLeftPadding;
    messageTextViewFrame.origin.y = kComposerBackgroundTopPadding;
    messageTextViewFrame.size.width = self.frame.size.width - kComposerBackgroundLeftPadding - kComposerTextViewButtonBetweenPadding - sendButtonFrame.size.width - kComposerBackgroundRightPadding;
    messageTextViewFrame.size.height = 34;
    self.messageTextView.frame = messageTextViewFrame;
    self.messageTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    self.messageTextView.showsHorizontalScrollIndicator = NO;
    self.messageTextView.layer.cornerRadius = 5;
    self.messageTextView.font = [UIFont systemFontOfSize:14];
    self.messageTextView.delegate = self;
    
    [self addNotifications];
    [self resizeTextViewForText:@"" animated:NO];
}

- (void)layoutSubviews {
    // Due to inconsistent handling of rotation when receiving UIDeviceOrientationDidChange notifications
    // ( see http://stackoverflow.com/q/19974246/740474 ) rotation handling is done here.
    CGFloat fixedWidth = self.messageTextView.frame.size.width;
    CGSize oldSize = self.messageTextView.frame.size;
    CGSize newSize = [self.messageTextView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    
    if (oldSize.height == newSize.height) {
        // In cases where the height remains the same after a rotation (AKA number of lines does not change)
        // this code is needed as resizeTextViewForText will not do any configuration.
        CGRect frame = self.frame;
        frame.origin.y = ([self currentScreenSize].height - [self currentKeyboardHeight]) - frame.size.height - keyboardOffset;
        self.frame = frame;
        
        // Even though the height didn't change the origin did so notify delegates
        if (self.delegate && [self.delegate respondsToSelector:@selector(messageComposerFrameDidChange:withAnimationDuration:)]) {
            [self.delegate messageComposerFrameDidChange:frame withAnimationDuration:keyboardAnimationDuration];
        }
    } else {
        // The view is already animating as part of the rotationso we just have to make sure it
        // snaps to the right place and resizes the textView to wrap the text with the new width. Changing
        // to add an additional animation will overload the animation and make it look like someone is
        // shuffling a deck of cards.
        [self resizeTextViewForText:self.messageTextView.text animated:NO];
    }
}


#pragma mark - NSNotification
- (void)addNotifications {
    NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(textViewTextDidChange:) name:UITextViewTextDidChangeNotification object:self.messageTextView];
    [defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)removeNotifications {
    NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self name:UITextViewTextDidChangeNotification object:self.messageTextView];
    [defaultCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}


#pragma mark - UITextViewDelegate
- (void)textViewTextDidChange:(NSNotification*)notification {
    NSString* newText = self.messageTextView.text;
    [self resizeTextViewForText:newText animated:YES];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageComposerUserTyping)])
        [self.delegate messageComposerUserTyping];
}

- (void)textViewDidBeginEditing:(UITextView*)textView {
    CGRect frame = self.frame;
    frame.origin.y = ([self currentScreenSize].height - [self currentKeyboardHeight]) - frame.size.height - keyboardOffset;
    
    [UIView animateWithDuration:keyboardAnimationDuration
                          delay:0.0
                        options:(keyboardAnimationCurve << 16)
                     animations:^{self.frame = frame;}
                     completion:nil];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageComposerFrameDidChange:withAnimationDuration:)]) {
        [self.delegate messageComposerFrameDidChange:frame withAnimationDuration:keyboardAnimationDuration];
    }
}

- (void)textViewDidEndEditing:(UITextView*)textView {
    CGRect frame = self.frame;
    frame.origin.y = [self currentScreenSize].height - self.frame.size.height - keyboardOffset;
    
    [UIView animateWithDuration:keyboardAnimationDuration
                          delay:0.0
                        options:(keyboardAnimationCurve << 16)
                     animations:^{self.frame = frame;}
                     completion:nil];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageComposerFrameDidChange:withAnimationDuration:)]) {
        [self.delegate messageComposerFrameDidChange:frame withAnimationDuration:keyboardAnimationDuration];
    }
}


#pragma mark - Keyboard Notifications
- (void)keyboardWillShow:(NSNotification*)notification {
    // Because keyboard animation time and cure vary by iOS version, and we don't want to build the library
    // on top of spammy keyboard notifications we use UIKeyboardWillShowNotification ONLY to dynamically set our
    // animation duration. As a UIKeyboardWillShowNotification is fired BEFORE textViewDidBeginEditing
    // is triggered we can use the following values for all of animations including the first.
    keyboardAnimationDuration = [[notification userInfo][UIKeyboardAnimationDurationUserInfoKey] floatValue];
    keyboardAnimationCurve = [[notification userInfo][UIKeyboardAnimationCurveUserInfoKey] intValue];
}


#pragma mark - TextView Frame Manipulation
- (void)resizeTextViewForText:(NSString*)text {
    [self resizeTextViewForText:text animated:NO];
}

- (void)resizeTextViewForText:(NSString*)text animated:(BOOL)animated {
    CGFloat fixedWidth = self.messageTextView.frame.size.width;
    CGSize oldSize = self.messageTextView.frame.size;
    CGSize newSize = [self.messageTextView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    
    // If the height doesn't need to change skip reconfiguration.
    if (oldSize.height == newSize.height) {
        return;
    }
    
    // Recalculate MessageComposerView container frame
    CGRect newContainerFrame = self.frame;
    newContainerFrame.size.height = newSize.height + kComposerBackgroundTopPadding + kComposerBackgroundBottomPadding;
    newContainerFrame.origin.y = ([self currentScreenSize].height - [self currentKeyboardHeight]) - newContainerFrame.size.height - keyboardOffset;;
    
    // Recalculate send button frame
    CGRect newSendButtonFrame = self.sendButton.frame;
    newSendButtonFrame.origin.y = newContainerFrame.size.height - (kComposerBackgroundBottomPadding + newSendButtonFrame.size.height);
    
    
    // Recalculate UITextView frame
    CGRect newTextViewFrame = self.messageTextView.frame;
    newTextViewFrame.size.height = newSize.height;
    newTextViewFrame.origin.y = kComposerBackgroundTopPadding;
    
    if (animated) {
        [UIView animateWithDuration:keyboardAnimationDuration
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             self.frame = newContainerFrame;
                             self.sendButton.frame = newSendButtonFrame;
                             self.messageTextView.frame = newTextViewFrame;
                             [self.messageTextView setContentOffset:CGPointMake(0, 0) animated:YES];
                         }
                         completion:nil];
    } else {
        self.frame = newContainerFrame;
        self.sendButton.frame = newSendButtonFrame;
        self.messageTextView.frame = newTextViewFrame;
        [self.messageTextView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageComposerFrameDidChange:withAnimationDuration:)]) {
        [self.delegate messageComposerFrameDidChange:newContainerFrame withAnimationDuration:keyboardAnimationDuration];
    }
}

- (void)scrollTextViewToBottom {
    [self.messageTextView scrollRangeToVisible:NSMakeRange([self.messageTextView.text length], 0)];
}


#pragma mark - IBAction
- (IBAction)sendClicked:(id)sender {
    if(self.delegate) {
        [self.delegate messageComposerSendMessageClickedWithMessage:self.messageTextView.text];
    }
    
    [self.messageTextView setText:@""];
    // Manually trigger the textViewDidChange method as setting the text when the messageTextView is not first responder the
    // UITextViewTextDidChangeNotification notification does not get fired.
    [self textViewTextDidChange:nil];
}


#pragma mark - Utils
- (UIInterfaceOrientation)currentInterfaceOrientation {
    // Returns the orientation of the Interface NOT the Device. The two do not happen in exact unison so
    // this point is important.
    return [UIApplication sharedApplication].statusBarOrientation;
}

- (float)currentKeyboardHeight {
    if ([self.messageTextView isFirstResponder]) {
        return [self currentKeyboardHeightInInterfaceOrientation:[self currentInterfaceOrientation]];
    } else {
        return 0;
    }
}

- (float)currentKeyboardHeightInInterfaceOrientation:(UIInterfaceOrientation)orientation {
    // TODO: this is very bad... another solution is needed or this will break on international keyboards etc.
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        return 162;
    } else {
        return 216;
    }
}

- (CGSize)currentScreenSize {
    // return the screen size with respect to the orientation
    return [self currentScreenSizeInInterfaceOrientation:[self currentInterfaceOrientation]];
}

- (CGSize)currentScreenSizeInInterfaceOrientation:(UIInterfaceOrientation)orientation {
    // http://stackoverflow.com/a/7905540/740474
    CGSize size = [UIScreen mainScreen].bounds.size;
    UIApplication *application = [UIApplication sharedApplication];
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        size = CGSizeMake(size.height, size.width);
    }
    if (application.statusBarHidden == NO && !([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)) {
        // if the status bar is not hidden subtract its height from the screensize.
        // NOTE: as of iOS 7 the status bar overlaps the application rather than sits on top of it, so hidden or not
        // its height is irrelevant in our position calculations.
        // see http://blog.jaredsinclair.com/post/61507315630/wrestling-with-status-bars-and-navigation-bars-on-ios-7
        size.height -= MIN(application.statusBarFrame.size.width, application.statusBarFrame.size.height);
    }
    return size;
}

- (void)startEditing {
    [self.messageTextView becomeFirstResponder];
}

- (void)finishEditing {
    [self.messageTextView resignFirstResponder];
}

@end
