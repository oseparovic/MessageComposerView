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

const int kTextViewTopOffset = 6;
const int kMessageBubbleInitialTopOffset = 10;
const int kMessageBubbleInitialHeight = 70;

const int kSendButtonWidth = 70;
const int kSendButtonActiveRightOffset = 5;

const int kProfileImageActiveRightOffset = 65;
const int kProfileImageInactiveRightOffset = 6;

const int kChatBubbleTailActiveRightOffset = 102;
const int kChatBubbleTailInactiveRightOffset = 42;

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
    [self addNotifications];
    self.showingCustomKeyboard = FALSE;
    self.messageTextPlaceholder = NSLocalizedString(@"LABEL.PLACEHOLDER.TYPE.MESSAGE", nil);
    self.messageTextView.showsHorizontalScrollIndicator = NO;
    
    self.textFieldImageView.image = [UIImage textFieldImage];
    
    [self.sendButton setBackgroundImage:[UIImage sendButtonImage] forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendButton.titleLabel setFont:[UIFont helveticaNeueRegular12]];
    [self.sendButton setTitle:NSLocalizedString(@"BUTTON.LABEL.SEND", nil) forState:UIControlStateNormal];
    
    self.chatBubbleTail.image = [UIImage messageComposerTail];
    
    [self.cameraButton setBackgroundImage:[UIImage cameraButtonImage] forState:UIControlStateNormal];
    [self.cameraButton setBackgroundImage:[UIImage cameraButtonImageSelected] forState:UIControlStateSelected];
    [self.cameraButton setBackgroundImage:[UIImage cameraButtonImageSelected] forState:UIControlStateHighlighted];
    
    //make the background image view clickable
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textBackgroundClicked:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.textFieldContainerView addGestureRecognizer:singleTap];
    [self.textFieldContainerView setUserInteractionEnabled:YES];
}

- (void)dealloc {
    [self removeNotifications];
}

- (void)toggleCustomKeyboardButtonsHidden:(BOOL)hidden {
    self.cameraButton.hidden = hidden;
    self.emojiButton.hidden = hidden;
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

- (void)textViewTextDidChange:(NSNotification*)notification {
    NSString* newText = self.messageTextView.text;
    [self resizeTextViewForText:newText];
    // show the send button after the first character is entered and keep it active until the user deletes their message
    if (!self.showingSendButton && newText.length >= 1) {
        [self showSendButton];
    } else if ([NSString isEmpty:newText]) {
        [self hideSendButton];
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(messageComposerUserTyping)])
        [self.delegate messageComposerUserTyping];
}

- (void)textViewDidBeginEditing:(UITextView*)textView {
    if(self.showingCustomKeyboard) {
        self.showingCustomKeyboard = FALSE;
        [self hideCustomKeyboard];
    }
    
    float keyboardHeight;
    if (UIInterfaceOrientationIsPortrait([BaseAppDelegate currentOrientation])) {
        keyboardHeight = KEYBOARD_PORTRAIT_HEIGHT;
    } else {
        keyboardHeight = KEYBOARD_LANDSCAPE_HEIGHT;
    }
    
    CGRect frame = self.frame;
    frame.origin.y = (self.superview.frame.size.height - keyboardHeight) - self.frame.size.height;
    
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
    if(self.showingCustomKeyboard || [self.messageTextView isFirstResponder]) {
        NSDictionary* userInfo = [notification userInfo];
        float animationTime = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
        
        CGRect frame = self.frame;

        if (UIInterfaceOrientationIsPortrait([BaseAppDelegate currentOrientation])) {
            frame.origin.y = (self.superview.frame.size.height - KEYBOARD_PORTRAIT_HEIGHT) - self.frame.size.height;
        } else {
            frame.origin.y = (self.superview.frame.size.height - KEYBOARD_LANDSCAPE_HEIGHT) - self.frame.size.height;
        }
        
        // we don't want to animate when rotating so that the message composer can stick to the keyboard
        self.frame = frame;
    
        if(self.delegate) {
            [self.delegate messageComposerFrameDidChange:frame withAnimationDuration:animationTime];
        }
        
        [self.emoticonReactionKeyboard reconfigurePageView];
    }
}

#pragma mark - custom keyboard display
- (void)showCustomKeyboard {
    self.showingCustomKeyboard = TRUE;
    [self.emoticonReactionKeyboard removeFromSuperview];
    
    [self.messageTextView resignFirstResponder];
    
    CGRect frame = self.emoticonReactionKeyboard.frame;
    frame.origin.x = 0;
    frame.origin.y = self.superview.frame.size.height;
    self.emoticonReactionKeyboard.frame = frame;
    [self.superview addSubview:self.emoticonReactionKeyboard];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        CGRect frame = self.frame;
        if ([BaseAppDelegate currentOrientation] == UIInterfaceOrientationPortrait) {
            frame.origin.y = [BaseAppDelegate currentSize].height - KEYBOARD_PORTRAIT_HEIGHT - self.frame.size.height - 44;
        } else {
            frame.origin.y = [BaseAppDelegate currentSize].height - KEYBOARD_LANDSCAPE_HEIGHT - self.frame.size.height;
        }
        self.frame = frame;
    } completion:^(BOOL finished) {}];
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.emoticonReactionKeyboard.frame;
        frame.origin.y = self.superview.frame.size.height - self.emoticonReactionKeyboard.frame.size.height;
        self.emoticonReactionKeyboard.frame = frame;
    }];
    
    if(self.delegate) {
        [self.delegate messageComposerFrameDidChange:self.frame withAnimationDuration:0.3];
    }
}

- (void)hideCustomKeyboard {
    self.showingCustomKeyboard = FALSE;
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        CGRect frame = self.frame;
        frame.origin.y = self.superview.frame.size.height - self.frame.size.height;
        self.frame = frame;
    } completion:^(BOOL finished) {}];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        CGRect frame = self.emoticonReactionKeyboard.frame;
        frame.origin.y = self.superview.frame.size.height;
        self.emoticonReactionKeyboard.frame = frame;
    } completion:^(BOOL finished) {
        [self.emoticonReactionKeyboard removeFromSuperview];
    }];
    
    if(self.delegate) {
        [self.delegate messageComposerFrameDidChange:self.frame withAnimationDuration:0.3];
    }
}

#pragma mark - TextView Frame Manipulation
- (void)resizeTextViewForText:(NSString*)text {
    CGSize textSize = [text sizeWithFont:self.messageTextView.font constrainedToSize:CGSizeMake(290, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    int numLines = self.messageTextView.contentSize.height / self.messageTextView.font.lineHeight;
    
    switch(numLines) {
        case 1:
        {
            if(self.textFieldImageView.frame.size.height != kMessageBubbleInitialHeight) {
                [UIView animateWithDuration:0.3
                                      delay:0
                                    options:UIViewAnimationOptionAllowUserInteraction
                                 animations:^{
                                     CGRect frame = self.textFieldImageView.frame;
                                     frame.origin.y = kMessageBubbleInitialTopOffset;
                                     frame.size.height = kMessageBubbleInitialHeight;
                                     self.textFieldImageView.frame = frame;
                                     frame.origin.y += 5;
                                     frame.size.height -= 5;
                                     self.textFieldContainerView.frame = frame;
                                     
                                     frame = self.messageTextView.frame;
                                     frame.origin.y = 0;
                                     frame.size.height = self.messageTextView.contentSize.height;
                                     self.messageTextView.frame = frame;
                                 } completion:nil];
            }
            break;
        }
        case 2:
        {
            if(self.textFieldImageView.frame.size.height != kMessageBubbleInitialHeight + 10) {
                [UIView animateWithDuration:0.3
                                      delay:0
                                    options:UIViewAnimationOptionAllowUserInteraction
                                 animations:^{
                                     CGRect frame = self.textFieldImageView.frame;
                                     frame.origin.y = kMessageBubbleInitialTopOffset - 10;
                                     frame.size.height = kMessageBubbleInitialHeight + 10;
                                     self.textFieldImageView.frame = frame;
                                     frame.origin.y += 5;
                                     frame.size.height -= 5;
                                     self.textFieldContainerView.frame = frame;
                                     
                                     frame = self.messageTextView.frame;
                                     frame.origin.y = 0;
                                     frame.size.height = self.messageTextView.contentSize.height;
                                     self.messageTextView.frame = frame;
                                 } completion:nil];
            }
            break;
        }
        case 3:
        default:
        {
            if(self.textFieldImageView.frame.size.height != kMessageBubbleInitialHeight + 20) {
                [UIView animateWithDuration:0.3
                                      delay:0
                                    options:UIViewAnimationOptionAllowUserInteraction
                                 animations:^{
                                     CGRect frame = self.textFieldImageView.frame;
                                     frame.origin.y = kMessageBubbleInitialTopOffset - 20;
                                     frame.size.height = kMessageBubbleInitialHeight + 20;
                                     self.textFieldImageView.frame = frame;
                                     frame.origin.y += 5;
                                     frame.size.height -= 5;
                                     self.textFieldContainerView.frame = frame;
                                     
                                     frame = self.messageTextView.frame;
                                     frame.origin.y = 0;
                                     frame.size.height = 51;
                                     self.messageTextView.frame = frame;
                                 } completion:nil];
            }
            break;
        }
    }
}

- (void)scrollTextViewToBottom {
    [self.messageTextView scrollRangeToVisible:NSMakeRange([self.messageTextView.text length], 0)];
}

#pragma mark - Send button handling
- (void)showSendButton {
    // move the send button into view
    self.showingSendButton = YES;
    CGRect frame = self.sendButton.frame;
    frame.size.width = kSendButtonWidth;
    frame.origin.x = self.frame.size.width - kSendButtonWidth - kSendButtonActiveRightOffset;
    [UIView animateWithDuration:0.55
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.sendButton.frame = frame;
                     }
                     completion:nil];
    
    frame = self.profileButton.frame;
    frame.origin.x = self.frame.size.width - self.profileButton.frame.size.width - kProfileImageActiveRightOffset;
    [UIView animateWithDuration:0.6
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.profileButton.frame = frame;
                     }
                     completion:nil];
    
    frame = self.chatBubbleTail.frame;
    frame.origin.x = self.frame.size.width - self.chatBubbleTail.frame.size.width - kChatBubbleTailActiveRightOffset;
    [UIView animateWithDuration:0.6
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.chatBubbleTail.frame = frame;
                     }
                     completion:nil];
}

- (void)hideSendButton {
    self.showingSendButton = NO;
    CGRect frame = self.sendButton.frame;
    frame.size.width = 0;
    frame.origin.x = self.frame.size.width;
    [UIView animateWithDuration:0.55
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.sendButton.frame = frame;
                     }
                     completion:nil];
    
    frame = self.profileButton.frame;
    frame.origin.x = self.frame.size.width - self.profileButton.frame.size.width - kProfileImageInactiveRightOffset;
    [UIView animateWithDuration:0.6
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.profileButton.frame = frame;
                     }
                     completion:nil];
    
    frame = self.chatBubbleTail.frame;
    frame.origin.x = self.frame.size.width - self.chatBubbleTail.frame.size.width - kChatBubbleTailInactiveRightOffset;
    [UIView animateWithDuration:0.6
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.chatBubbleTail.frame = frame;
                     }
                     completion:nil];
}

- (void)setMessageTextPlaceholder:(NSString *)messageTextPlaceholder {
    _messageTextPlaceholder = messageTextPlaceholder;
    self.messageTextView.placeholder = messageTextPlaceholder;
}


#pragma mark - IBAction
- (IBAction)emoticonButtonClicked:(id)sender {
    if(self.delegate) {
        if(self.showingCustomKeyboard) {
            [self hideCustomKeyboard];
        } else {
            [self showCustomKeyboard];
        }
    }
}

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
@end
