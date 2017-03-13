//
//  TLTableViewCell.h
//  ESLListening
//
//  Created by NguyenThanhLuan on 19/12/2016.
//  Copyright © 2016 Olala. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum LessonState: NSUInteger {
    kNone,
    kPass,
    kFail,
} LessonState;

@interface TLTableViewCell : UITableViewCell{
    LessonState     _state;
}

@property (assign,nonatomic) LessonState  state;

@property (weak, nonatomic) IBOutlet UIImageView *avata;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *lastOpenDate;

@end
