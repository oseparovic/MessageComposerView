#import "MessageComposerView.h"

@interface MessageComposerView()
- (void)addNotifications;
- (void)removeNotifications;
- (void)textViewTextDidChange:(NSNotification*)notification;
- (void)resizeTextViewForText:(NSString*)text;
- (void)showSendButton;
- (void)hideSendButton;
@end

@implementation MessageComposerView

const int KEYBOARD_PORTRAIT_HEIGHT = 216;
const int KEYBOARD_LANDSCAPE_HEIGHT = 162;

const int kComposerBackgroundTopPadding = 10;
const int kComposerBackgroundBottomPadding = 10;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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
    [self addNotifications];
    
    self.sendButton.layer.cornerRadius = 5;
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    [self.sendButton setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [self.sendButton setBackgroundColor:[UIColor orangeColor]];

    self.messageTextView.showsHorizontalScrollIndicator = NO;
    self.messageTextView.layer.cornerRadius = 5;
    [self resizeTextViewForText:@"" animated:NO];
}


#pragma mark - NSNotification
- (void)addNotifications {
    NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(textViewTextDidChange:) name:UITextViewTextDidChangeNotification object:self.messageTextView];
    [defaultCenter addObserver:self selector:@selector(handleRotation:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)removeNotifications {
    NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self name:UITextViewTextDidChangeNotification object:self.messageTextView];
    [defaultCenter removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}


#pragma mark - UITextViewDelegate
- (void)textViewTextDidChange:(NSNotification*)notification {
    NSString* newText = self.messageTextView.text;
    [self resizeTextViewForText:newText animated:YES];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(messageComposerUserTyping)])
        [self.delegate messageComposerUserTyping];
}

- (void)textViewDidBeginEditing:(UITextView*)textView {
    CGRect frame = self.frame;
    frame.origin.y = (self.superview.frame.size.height - [self currentKeyboardHeight]) - self.frame.size.height;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = frame;
    }];
    
    if(self.delegate) {
        [self.delegate messageComposerFrameDidChange:frame withAnimationDuration:0.3];
    }
}

- (void)textViewDidEndEditing:(UITextView*)textView {
    CGRect frame = self.frame;
    frame.origin.y = self.superview.frame.size.height - self.frame.size.height;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = frame;
    }];
    
    if(self.delegate) {
        [self.delegate messageComposerFrameDidChange:frame withAnimationDuration:0.3];
    }
}

- (void)handleRotation:(NSNotification*)notification {
    if([self.messageTextView isFirstResponder]) {
        NSDictionary* userInfo = [notification userInfo];
        float animationTime = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
        
        CGRect frame = self.frame;
        frame.origin.y = (self.superview.frame.size.height - [self currentKeyboardHeight]) - self.frame.size.height;
        self.frame = frame;
    
        if(self.delegate) {
            [self.delegate messageComposerFrameDidChange:frame withAnimationDuration:animationTime];
        }
    }
}


#pragma mark - TextView Frame Manipulation
- (void)resizeTextViewForText:(NSString*)text {
    [self resizeTextViewForText:text animated:NO];
}

- (void)resizeTextViewForText:(NSString*)text animated:(BOOL)animated {
    CGFloat fixedWidth = self.messageTextView.frame.size.width;
    CGSize oldSize = self.messageTextView.frame.size;
    CGSize newSize = [self.messageTextView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    
    // if the height doesn't need to change skip reconfiguration
    if (oldSize.height == newSize.height) {
        return;
    }
    
    // recalculate composer view container frame
    CGRect newContainerFrame = self.frame;
    newContainerFrame.size.height = newSize.height + kComposerBackgroundTopPadding + kComposerBackgroundBottomPadding;
    newContainerFrame.origin.y = (self.superview.frame.size.height - [self currentKeyboardHeight]) - newContainerFrame.size.height;
    
    // recalculate send button frame
    CGRect newSendButtonFrame = self.sendButton.frame;
    newSendButtonFrame.origin.y = newContainerFrame.size.height - (kComposerBackgroundBottomPadding + newSendButtonFrame.size.height);
    
    
    // recalculate UITextView frame
    CGRect newTextViewFrame = self.messageTextView.frame;
    newTextViewFrame.size.height = newSize.height;
    newTextViewFrame.origin.y = kComposerBackgroundTopPadding;
    
    if (animated) {
        [UIView animateWithDuration:0.3
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
    
    if (self.delegate) {
        [self.delegate messageComposerFrameDidChange:newContainerFrame withAnimationDuration:0.3];
    }
}

- (void)textBackgroundClicked:(id)sender {
    [self.messageTextView becomeFirstResponder];
}

- (void)scrollTextViewToBottom {
    [self.messageTextView scrollRangeToVisible:NSMakeRange([self.messageTextView.text length], 0)];
}


#pragma mark - IBAction
- (IBAction)sendClicked:(id)sender {
    if(self.delegate) {
        [self.delegate messageComposerSendMessageClickedWithMessage:self.messageTextView.text];
    }
    
    if ([self.messageTextView isFirstResponder]) {
        [self.messageTextView setText:@""];
    } else {
        [self.messageTextView setText:@""];
        // manually trigger the textViewDidChange method as setting the text when the messageTextView is not first responder the
        // UITextViewTextDidChangeNotification notification does not get fired.
        [self textViewTextDidChange:nil];        
    }
}


#pragma mark - Utils
- (UIInterfaceOrientation)currentOrientation {
    return [UIApplication sharedApplication].statusBarOrientation;
}

- (float)currentKeyboardHeight {
    float keyboardHeight;
    if (UIInterfaceOrientationIsPortrait([self currentOrientation])) {
        keyboardHeight = KEYBOARD_PORTRAIT_HEIGHT;
    } else {
        keyboardHeight = KEYBOARD_LANDSCAPE_HEIGHT;
    }
    return keyboardHeight;
}


#pragma mark - unused
- (void)showCustomKeyboard {
}
- (void)hideCustomKeyboard {
}
- (void)toggleCustomKeyboardButtonsHidden:(BOOL)hidden {
}
- (void)showSendButton {
}
- (void)hideSendButton {
}
- (void)setMessageTextPlaceholder:(NSString *)messageTextPlaceholder {
}

@end
