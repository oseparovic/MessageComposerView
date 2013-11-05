MessageComposerView
===================

If you find yourself needing a textview that sticks to the keyboard and does *not* disappear when the keyboard hides, you'll quickly find that there is no clean way of doing it. `MessageComposerView` is a custom view implementation that aims to fill that void. Rather that being an inputAccessoryView once added to your viewcontroller it will automatically "follow" the keyboard, handling rotation showing and hiding etc.

Usage
=====
####Instantiation
Instantiate and add `MessageComposerView` to the bottom of your view controller. Example: 

    self.messageComposerView = [[NSBundle mainBundle] loadNibNamed:@"MessageComposerView" owner:nil options:nil][0];
    self.messageComposerView.delegate = self;
####Delegation
The `MessageComposerViewDelegate` has several delegate methods:

1. **Required** `- (void)messageComposerSendMessageClickedWithMessage:(NSString*)message;`. This delegate method is triggered when the user presses the send button. The message is the message within the UITextView at the time the button was pressed.
2. **Optional** `- (void)messageComposerFrameDidChange:(CGRect)frame withAnimationDuration:(float)duration;`
3. **Optional** `- (void)messageComposerUserTyping;`. Triggered whenever the UITextView text changes.
