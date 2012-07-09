//
//  CCBViewController.h
//  DatabaseConnector
//
//  Created by Eugeniusz Keptia on 7/4/12.
//  Copyright (c) 2012 edzio27developer@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface CCBViewController : UIViewController
{
    IBOutlet UITextView *myTextView;
    sqlite3 *database;
}

@property (nonatomic) sqlite3 *database;

- (void) createDatabase;
- (void) createDictionary;
- (void) connectingWithDatabase;
- (void) insertingToDatabase;

@end
