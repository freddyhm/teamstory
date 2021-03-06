//
//  KonotorConversationViewController.h
//  KonotorSampleApp
//
//  Created by Srikrishnan Ganesan on 08/07/13.
//  Copyright (c) 2013 Demach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Konotor.h"
#import "KonotorUI.h"

/* DO NOT ALTER - THESE ARE FOR REFERENCE OF DEFAULT VALUES FOR CALLOUT PROVIDED */
#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_INSET_DEFAULTCALLOUT 25
#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_LEFT_INSET_DEFAULTCALLOUT 25
#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_RIGHT_INSET_DEFAULTCALLOUT 28
#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_BOTTOM_INSET_DEFAULTCALLOUT 28
#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING_DEFAULT 20
#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_SIDE_PADDING_DEFAULT 0
#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_BOTTOM_PADDING_DEFAULT 20

#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_INSET_IMESSAGECALLOUT 16
#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_LEFT_INSET_IMESSAGECALLOUT 14
#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_RIGHT_INSET_IMESSAGECALLOUT 28
#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_BOTTOM_INSET_IMESSAGECALLOUT 36
#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_SIDE_PADDING_IMESSAGE 10
/* END OF DEFAULT SECTION */

#define KONOTOR_MESSAGETEXT_FONT ([UIFont fontWithName:@"HelveticaNeue-Light" size:16.0])


#define TRANSPARENT_COLOR ([UIColor clearColor])
#define WHITE_COLOR ([UIColor whiteColor])
#define KONOTOR_LIGHTGRAY_COLOR ([UIColor colorWithRed:0.9 green:0.9 blue:0.91 alpha:1.0])
#define KONOTOR_CREAM_COLOR ([UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0])

#define KONOTOR_REFRESHINDICATOR_TAG 80
#define KONOTOR_MESSAGETEXTVIEW_TAG 81
#define KONOTOR_CALLOUT_TAG 82
#define KONOTOR_PLAYBUTTON_TAG 83
#define KONOTOR_PROFILEIMAGE_TAG 84
#define KONOTOR_USERNAMEFIELD_TAG 85
#define KONOTOR_TIMEFIELD_TAG 86
#define KONOTOR_UPLOADSTATUS_TAG 87
#define KONOTOR_DURATION_TAG 88

#define KONOTOR_AUDIOMESSAGE_HEIGHT 42
#define KONOTOR_PROFILEIMAGE_DIMENSION 40
#define KONOTOR_PLAYBUTTON_DIMENSION 40
#define KONOTOR_HORIZONTAL_PADDING 5
#define KONOTOR_VERTICAL_PADDING 2
#define KONOTOR_ENDOFMESSAGE_HORIZONTAL_PADDING 10
#define KONOTOR_USERNAMEFIELD_HEIGHT 18
#define KONOTOR_TIMEFIELD_HEIGHT 16

#define KONOTOR_SHOW_TIMESTAMP YES
#define KONOTOR_SHOW_SENDERNAME NO
#define KONOTOR_SHOW_DURATION NO
#define KONOTOR_SHOW_UPLOADSTATUS (KONOTOR_SHOW_TIMESTAMP||KONOTOR_SHOW_SENDERNAME)
#define KONOTOR_TEXTMESSAGE_MAXWIDTH 260.0

#define KONOTOR_USERMESSAGE_TEXT_COLOR ([UIColor whiteColor])
#define KONOTOR_OTHERMESSAGE_TEXT_COLOR ([UIColor blackColor])
#define KONOTOR_USERTIMESTAMP_COLOR KONOTOR_LIGHTGRAY_COLOR
#define KONOTOR_OTHERTIMESTAMP_COLOR ([UIColor darkGrayColor])
#define KONOTOR_USERNAME_TEXT_COLOR ([UIColor whiteColor])
#define KONOTOR_OTHERNAME_TEXT_COLOR ([UIColor darkGrayColor])

#if KONOTOR_IMESSAGE_LAYOUT
#define KONOTOR_SHOWPROFILEIMAGE NO
#define KONOTOR_USESCALLOUTIMAGE YES
#else
#define KONOTOR_SHOWPROFILEIMAGE YES
#define KONOTOR_USESCALLOUTIMAGE NO
#endif

#if KONOTOR_IMESSAGE_LAYOUT
#define KONOTOR_MESSAGE_BACKGROUND_COLOR TRANSPARENT_COLOR
#define KONOTOR_MESSAGELAYOUT_BACKGROUND_COLOR ([UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1.0])
#define KONOTOR_SUPPORTMESSAGE_BACKGROUND_COLOR TRANSPARENT_COLOR
#else
#define KONOTOR_MESSAGE_BACKGROUND_COLOR KONOTOR_LIGHTGRAY_COLOR
#define KONOTOR_MESSAGELAYOUT_BACKGROUND_COLOR WHITE_COLOR
#define KONOTOR_SUPPORTMESSAGE_BACKGROUND_COLOR KONOTOR_CREAM_COLOR
#endif

#if KONOTOR_IMESSAGE_LAYOUT
#define KONOTOR_SMART_TIMESTAMP 1
#else
#define KONOTOR_SMART_TIMESTAMP 1
#endif

#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_INSET KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_INSET_IMESSAGECALLOUT
#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_LEFT_INSET KONOTOR_MESSAGE_BACKGROUND_IMAGE_LEFT_INSET_IMESSAGECALLOUT
#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_RIGHT_INSET KONOTOR_MESSAGE_BACKGROUND_IMAGE_RIGHT_INSET_IMESSAGECALLOUT
#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_BOTTOM_INSET KONOTOR_MESSAGE_BACKGROUND_IMAGE_BOTTOM_INSET_IMESSAGECALLOUT

#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING_DEFAULT

#if KONOTOR_IMESSAGE_LAYOUT
#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_SIDE_PADDING KONOTOR_MESSAGE_BACKGROUND_IMAGE_SIDE_PADDING_IMESSAGE
#else
#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_SIDE_PADDING KONOTOR_MESSAGE_BACKGROUND_IMAGE_SIDE_PADDING_DEFAULT
#endif

#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_BOTTOM_PADDING 12
#define KONOTOR_MESSAGE_BACKGROUND_TOP_PADDING_ME NO
#define KONOTOR_MESSAGE_BACKGROUND_TOP_PADDING_OTHER NO
#define KONOTOR_MESSAGE_BACKGROUND_BOTTOM_PADDING_ME NO
#define KONOTOR_MESSAGE_BACKGROUND_BOTTOM_PADDING_OTHER NO


@interface KonotorConversationViewController : UITableViewController <KonotorDelegate,UIAlertViewDelegate>

- (void) refreshView;

@end
