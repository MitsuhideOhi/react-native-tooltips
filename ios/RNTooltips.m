
#import "RNTooltips.h"

@implementation RNTooltips

@synthesize bridge = _bridge;

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()


RCT_EXPORT_METHOD(Show:(nonnull NSNumber *)view props:(NSDictionary *)props)
{
    UIView *target = [self.bridge.uiManager viewForReactTag: view];
    
    NSString *text = [props objectForKey: @"text"];
    NSNumber *position = [props objectForKey: @"position"];
    NSNumber *align = [props objectForKey: @"align"];
    NSNumber *autoHide = [props objectForKey: @"autoHide"];
    NSNumber *duration = [props objectForKey: @"duration"];
    NSNumber *clickToHide = [props objectForKey: @"clickToHide"];
    NSNumber *corner = [props objectForKey: @"corner"];
    NSString *tintColor = [props objectForKey: @"tintColor"];
    NSString *textColor = [props objectForKey: @"textColor"];
    NSNumber *textSize = [props objectForKey: @"textSize"];
    NSNumber *gravity = [props objectForKey: @"gravity"];
    NSNumber *shadow = [props objectForKey: @"shadow"];

    NSMutableAttributedString *attributes = [[NSMutableAttributedString alloc] initWithString: text];
    [attributes addAttribute:NSForegroundColorAttributeName value:[RNTooltips colorFromHexCode: textColor] range:NSMakeRange(0, text.length)];
    [attributes addAttribute:NSFontAttributeName value: [UIFont systemFontOfSize: [textSize floatValue]] range:NSMakeRange(0,text.length)];

    SexyTooltip *toolTip = [[SexyTooltip alloc] initWithAttributedString: attributes];
    toolTip.color = [RNTooltips colorFromHexCode: tintColor];
    toolTip.cornerRadius = [corner floatValue];
    toolTip.dismissesOnTap = [clickToHide boolValue];
    toolTip.padding = UIEdgeInsetsMake(6, 8, 6, 8);
    
    if (position != nil) {
        NSDictionary *mapper = @{
                                 @"1" : @(SexyTooltipArrowDirectionLeft),
                                 @"2" : @(SexyTooltipArrowDirectionRight),
                                 @"3" : @(SexyTooltipArrowDirectionDown),
                                 @"4" : @(SexyTooltipArrowDirectionUp),
                                 };
        NSNumber *permittedArrowDirection = mapper[[position stringValue]];
        if (permittedArrowDirection != nil) {
            tooltip.permittedArrowDirections = @[position];
        }
    }

    if ([shadow boolValue]) {
        toolTip.hasShadow = YES;
    }
    if ([autoHide boolValue]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [toolTip dismissInTimeInterval:(NSTimeInterval) [duration floatValue] animated: YES];
            // Timer here
        });
    }

    [toolTip presentFromView:target animated:YES];
}


+ (UIColor *) colorFromHexCode:(NSString *)hexString {
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if([cleanString length] == 3) {
        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                       [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
                       [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
                       [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
    }
    if([cleanString length] == 6) {
        cleanString = [cleanString stringByAppendingString:@"ff"];
    }
    
    unsigned int baseValue;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
    
    float red = ((baseValue >> 24) & 0xFF)/255.0f;
    float green = ((baseValue >> 16) & 0xFF)/255.0f;
    float blue = ((baseValue >> 8) & 0xFF)/255.0f;
    float alpha = ((baseValue >> 0) & 0xFF)/255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}


@end
  
