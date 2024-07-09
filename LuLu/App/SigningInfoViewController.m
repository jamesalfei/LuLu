//
//  file: SigningInfoViewController
//  project: lulu (login item)
//  description: view controller for signing info popup (header)
//
//  created by Patrick Wardle
//  copyright (c) 2018 Objective-See. All rights reserved.
//

#import "consts.h"
#import "utilities.h"
#import "SigningInfoViewController.h"

@implementation SigningInfoViewController

@synthesize alert;

//automatically invoked
-(void)popoverWillShow:(NSNotification *)notification;
{
    //signing info
    NSDictionary* signingInfo = nil;
    
    //summary
    NSMutableString* summary = nil;
    
    //alloc string for summary
    summary = [NSMutableString string];

    //extract signing info
    signingInfo = alert[KEY_CS_INFO];
    
    //start summary with item name
    [summary appendString:alert[KEY_PROCESS_NAME]];
    
    //unset signing auth field
    for(NSUInteger i=0; i<3; i++)
    {
        //unset
        ((NSTextField*)[self.view viewWithTag:SIGNING_AUTH_1+i]).stringValue = @"";
    }

    //no signing info?
    if(nil == signingInfo)
    {
        //append to summary
        [summary appendFormat:NSLocalizedString(@" is not validly signed", @" is not validly signed")];
        
        //details: n/a
        self.details.stringValue = NSLocalizedString(@"not applicable", @"not applicable");
        
        //signing id: n/a
        self.signingID.stringValue = NSLocalizedString(@"not applicable", @"not applicable");
        
        //bail
        goto bail;
    }

    //process
    switch([signingInfo[KEY_CS_STATUS] integerValue])
    {
        //happily signed
        case noErr:
            
            //append to summary
            [summary appendFormat:NSLocalizedString(@" is validly signed", @" is validly signed")];
            
            //item signed by apple
            if(Apple == [signingInfo[KEY_CS_SIGNER] intValue])
            {
                //set details
                self.details.stringValue = NSLocalizedString(@"signed by Apple proper", @"signed by Apple proper");
            }
            //item signed, third party/ad hoc, etc
            else
            {
                //from app store?
                if(AppStore == [signingInfo[KEY_CS_SIGNER] intValue])
                {
                    //set details
                    self.details.stringValue = NSLocalizedString(@"signed by Mac App Store", @"signed by Mac App Store");
                }
                //developer id?
                else if(DevID == [signingInfo[KEY_CS_SIGNER] intValue])
                {
                    //set details
                    self.details.stringValue = NSLocalizedString(@"signed with an Apple Developer ID", @"signed with an Apple Developer ID");
                }
                //something else
                // ad hoc? 3rd-party?
                else if(AdHoc == [signingInfo[KEY_CS_SIGNER] intValue])
                {
                    //set details
                    self.details.stringValue = NSLocalizedString(@" signed by 3rd-party/ad hoc", @" signed by 3rd-party/ad hoc");
                }
                else
                {
                    //set details
                    self.details.stringValue = NSLocalizedString(@" unknown", @" unknown");
                }
            }
            
            //no signing auths
            // usually (always?) adhoc
            if(0 == [signingInfo[KEY_CS_AUTHS] count])
            {
                //set details
                self.details.stringValue = NSLocalizedString(@"signed, but no signing authorities (adhoc?)", @"signed, but no signing authorities (adhoc?)");
                
                //set signing auth field
                ((NSTextField*)[self.view viewWithTag:SIGNING_AUTH_1]).stringValue = NSLocalizedString(@"› no signing authorities", @"› no signing authorities");
            }
            
            //add each signing auth
            // should one be max of three
            else
            {
                //add signing auth
                for(NSUInteger i=0; i<[signingInfo[KEY_CS_AUTHS] count]; i++)
                {
                    //exit loop at three
                    if(i == 3) break;
                        
                    //add
                    ((NSTextField*)[self.view viewWithTag:SIGNING_AUTH_1+i]).stringValue = [NSString stringWithFormat:@"› %@ \n", signingInfo[KEY_CS_AUTHS][i]];
                }
            }
            
            //set signing id
            if(nil != signingInfo[KEY_CS_ID])
            {
                //set
                self.signingID.stringValue = signingInfo[KEY_CS_ID];
            }
            
            break;
            
        //unsigned
        case errSecCSUnsigned:
            
            //append to summary
            [summary appendFormat:NSLocalizedString(@" is not signed", @" is not signed")];
            
            //details: n/a
            self.details.stringValue = NSLocalizedString(@"not applicable", @"not applicable");
            
            //signing id: n/a
            self.signingID.stringValue = NSLocalizedString(@"not applicable", @"not applicable");
            
            break;
            
        //everything else
        // other signing errors
        default:
            
            //append to summary
            [summary appendFormat:NSLocalizedString(@" has a signing issue", @" has a signing issue")];
            
            //set details
            self.details.stringValue = [NSMutableString stringWithFormat:NSLocalizedString(@"signing error: %#lx", @"signing error: %#lx"), (long)[signingInfo[KEY_CS_STATUS] integerValue]];
            
            //set signing id
            if(nil != signingInfo[KEY_CS_ID])
            {
                //set
                self.signingID.stringValue = signingInfo[KEY_CS_ID];
            }
            
            break;
    }
    
bail:
    
    //no (valid) signing auths?
    // show 'not applicable' msg
    if(0 == [((NSTextField*)[self.view viewWithTag:SIGNING_AUTH_1]).stringValue length])
    {
        //show
        self.noSigningAuths.hidden = NO;
    }
    
    //assign summary to outlet
    self.message.stringValue = summary;
    
    return;
}

@end
