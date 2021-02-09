//
//  IOSNativeAlert.m
//  Alert
//
//  Created by Nrjwolf on 04/12/2019.
//  Copyright © 2019 Nrjwolf. All rights reserved.
//

extern UIViewController *UnityGetGLViewController();

NSString *ToNSString(char* string) {
    return [NSString stringWithUTF8String:string];
}

// Unity button delegate delegate
typedef void (*MonoPAlertButtonDelegate)(const char* buttonId);
static MonoPAlertButtonDelegate _onButtonClick = NULL;

// Register unity message handler
FOUNDATION_EXPORT void IOSRegisterMessageHandler(MonoPAlertButtonDelegate onButtonClick)
{
    _onButtonClick = onButtonClick;
}

// Send message to unity
void SendMessageToUnity(const char* buttonId) {
    NSLog(@"Clicked %s", buttonId);
    if(_onButtonClick != NULL) {
        _onButtonClick(buttonId);
    }
}

// Alert function
void _IOSShowAlertMsg (int alertStyle, char* title, char* message, char* buttons[], int buttonsStyle[], int buttonsLength) {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle : ToNSString(title) message : ToNSString(message) preferredStyle : (UIAlertControllerStyle)alertStyle];

    // Add buttons
    if (buttons && buttonsLength > 0) {
        for (int i = 0; i < buttonsLength; i++) {
            NSString *buttonTitle = ToNSString(buttons[i]);
            UIAlertActionStyle style = (UIAlertActionStyle)buttonsStyle[i];
            UIAlertAction * button = [UIAlertAction actionWithTitle: buttonTitle style:style handler:^(UIAlertAction * action) {
                NSString* buttonId = [NSString stringWithFormat:@"%@%d", buttonTitle, i];
                SendMessageToUnity((char*)[buttonId UTF8String]);
            }];
            [alert addAction:button];
        }
    }

    if let popoverController = alert.popoverPresentationController {
        popoverController.sourceView = self.TARGET_OBJECT // TARGET_OBJECT will be your sender to show an alert from.
        popoverController.sourceRect = CGRect(x: self.TARGET_OBJECT.frame.size.width/2, y: self.TARGET_OBJECT.frame.size.height/2, width: 0, height: 0)
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [UnityGetGLViewController() presentViewController:alert animated:YES completion:nil];
    });
}

/// Show something like android toast
void _IOSShowToast (char* message, BOOL isLongDuration) {
    NSString *messageString = ToNSString(message);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                message:messageString
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [UnityGetGLViewController() presentViewController:alert animated:YES completion:nil];
    int duration = isLongDuration ? 1 : .5;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:nil];
    });
}
