MessageComposerView
===================

If you find yourself needing a textview that sticks to the keyboard and does *not* disappear when the keyboard hides, you'll quickly find that there is no clean way of doing it. `MessageComposerView` is a custom view implementation that aims to fill that void. Rather that being an `inputAccessoryView` once added to your `ViewController` it will automatically "follow" the keyboard, handling rotation showing and hiding etc.

Usage
=====
####Instantiation
Instantiate and add `MessageComposerView` to the bottom of your view controller. Example: 

    self.messageComposerView = [[NSBundle mainBundle] loadNibNamed:@"MessageComposerView" owner:nil options:nil][0];
    self.messageComposerView.delegate = self;
    self.messageComposerView.frame = CGRectMake(0,
                                                self.view.frame.size.height - self.messageComposerView.frame.size.height,
                                                self.messageComposerView.frame.size.width,
                                                self.messageComposerView.frame.size.height);
    [self.view addSubview:self.messageComposerView];
    
![](http://www.thegameengine.org/wp-content/uploads/2013/11/message_composer_quad_1.jpg)  
The `MessageComposerViewDelegate` has several delegate methods:

1. **Required** `- (void)messageComposerSendMessageClickedWithMessage:(NSString*)message;`  
Triggered whenever the user presses the send button. The message is the message within the UITextView at the time the button was pressed.

2. **Optional** `- (void)messageComposerFrameDidChange:(CGRect)frame withAnimationDuration:(float)duration;`  
Triggered whenever the UITextView frame is reconfigured.

3. **Optional** `- (void)messageComposerUserTyping;`  
Triggered whenever the UITextView text changes.
