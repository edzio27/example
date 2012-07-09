//
//  CCBViewController.m
//  DatabaseConnector
//
//  Created by Eugeniusz Keptia on 7/4/12.
//  Copyright (c) 2012 edzio27developer@gmail.com. All rights reserved.
//

#import "CCBViewController.h"
#import <CCBDatabaseConnect/CCBDatabaseConnect.h>

@interface CCBViewController ()
{
    const char *dbpath;
    char *error;
}

@property (nonatomic, retain) NSDictionary *tableValue;
@property (nonatomic, retain) NSString *databasePath;
@property (nonatomic, retain) NSArray *arrayPath;
@property (nonatomic, retain) NSString *databaseDir;
@property (nonatomic, retain) CCBDatabaseInit *initializator;
@end

@implementation CCBViewController
@synthesize tableValue;
@synthesize databasePath;
@synthesize databaseDir;
@synthesize arrayPath;
@synthesize initializator;
@synthesize database;

#pragma mark create dictionary
- (void) createDictionary
{
    NSArray *keys = [[NSArray alloc] initWithObjects:@"jeden", @"dwa", @"trzy", nil];
    NSArray *values = [[NSArray alloc] initWithObjects:@"111", @"222", @"333", nil];
    tableValue = [NSDictionary dictionaryWithObjects:values forKeys:keys];
}
#pragma end

#pragma mark creating&editing database

- (void)createEditableCopyOfDatabaseIfNeeded {
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *dbError;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"baza.sqlite"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    NSLog(@"Writable database path: %@", writableDBPath);
    if (success) {
        //[fileManager removeItemAtPath:writableDBPath error:nil];
        return;
    }
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"baza.sqlite"];
    NSLog(@"Default database path: %@", defaultDBPath);
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&dbError];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [dbError localizedDescription]);
    }
}

- (void) createDatabase {
    arrayPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    databaseDir = [arrayPath objectAtIndex:0];
    databasePath = [databaseDir stringByAppendingString:[@"/" stringByAppendingString: @"baza.sqlite"]];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:databasePath] == YES) {
        NSLog(@"Database exists..."); 
        dbpath = [databasePath UTF8String];
        if( sqlite3_open( dbpath, &database ) == SQLITE_OK ) {
            NSLog(@"..and it was opened");
            const char *sql_stm = "CREATE TABLE tablica1 (key TEXT, value TEXT)";
            if ( sqlite3_exec(database, sql_stm, NULL, NULL, &error) == SQLITE_OK) {
                NSLog(@"table was created");
            }
        }
    }
    else {
        dbpath = [databasePath UTF8String];
        if( sqlite3_open( dbpath, &database ) == SQLITE_OK ) {
            const char *sql_stm = "CREATE TABLE tablica1 (key TEXT, value TEXT)";
            if ( sqlite3_exec(database, sql_stm, NULL, NULL, &error) == SQLITE_OK) {
                NSLog(@"table was created");
            }
            else {
                NSLog(@"table hasnt been created");
            }
        }
        else {
            NSLog(@"Database hasnt been opened");
        }
    }
}

- (void) connectingWithDatabase {
    sqlite3_stmt *statement;
    initializator = [[CCBDatabaseInit alloc] initWithBaseName:@"baza.sqlite"];
    statement = [initializator getStatement:@"SELECT key, value FROM tablica1"];

    while (sqlite3_step(statement) == SQLITE_ROW) {
            NSString *klucz = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)];
            NSString *wartosc = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 1)];
            NSLog(@"klucz %@", klucz);
            NSString *temporary = [[NSString alloc] initWithString: [myTextView.text stringByAppendingString: [klucz stringByAppendingString: [wartosc stringByAppendingString:@"\n"]] ]];
            myTextView.text = temporary;
    }
}

- (void) insertingToDatabase {
    for (NSString* key in tableValue) {
        NSString *value = [tableValue objectForKey:key];
        sqlite3_stmt *statement;
        NSString *query = [NSString stringWithFormat: @"INSERT INTO tablica1 (key, value) VALUES (?,?)"];
        const char *sql = [query UTF8String];
        sqlite3_prepare_v2(database, sql, -1, &statement, NULL);        
        
        sqlite3_bind_text(statement, 1, [key UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [value UTF8String], -1, SQLITE_TRANSIENT);
        
        if(sqlite3_step(statement) != SQLITE_DONE ) {
            NSLog( @"Error: %s", sqlite3_errmsg(database) );
        } else {
            NSLog( @"Row has been inserted");
        }
        
    }
}
#pragma end

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createDictionary];
    [self createEditableCopyOfDatabaseIfNeeded];
    [self createDatabase];
    [self insertingToDatabase];
    [self connectingWithDatabase];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
