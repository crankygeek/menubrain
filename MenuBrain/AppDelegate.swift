//
//  AppDelegate.swift
//  MenuBrain
//
//  Created by John Marstall on 7/30/15.
//  Copyright (c) 2015 John Marstall. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var stringArray:NSMutableArray = [""]
    var firstRun: Bool = true
    var insertionPoint = 0
    
    var brainArray: NSMutableArray = [""]
    var statusBar = NSStatusBar.systemStatusBar()
    var statusBarItem : NSStatusItem = NSStatusItem()
    var brainMenu: NSMenu = NSMenu()
    var brainMenuItem : NSMenuItem = NSMenuItem()

    @IBOutlet weak var menuBrainWindow: NSWindow!
    @IBOutlet weak var brainTable: NSTableView!
    
    @IBOutlet weak var inputField: AXCVHandler!
    @IBOutlet weak var window: NSWindow!
    
    @IBAction func addString(sender: AnyObject) {
        let newString: NSString = inputField.stringValue
        
        if (newString.length == 0)
        {
            return
        }
        
        if (firstRun == true) {
            //need to remove Getting Started item and replace it with the first user item
            print("Trying to remove Getting Started item")
            brainMenu.removeItemAtIndex(0)
            firstRun = false
        } else {
            print("App has been launched previously")
        }
        
        brainArray.addObject(newString)
        print("Added %@", brainArray.lastObject)
        inputField.stringValue = ""
        
        //Add string to status menu
        
        self.addMenuBrainMenuItem(newString, rowIndex: insertionPoint)

        
        insertionPoint++
        
        self.refreshAll()
    }

    @IBAction func removeString(sender: AnyObject) {
        var row = brainTable.selectedRow
        if (row == -1) {
            print("selection changed to row \(row)")
            return
        } else {
            stringArray.removeObjectAtIndex(row)
            brainMenu.removeItemAtIndex(row)
            self.refreshAll()
        }
        
        insertionPoint--
        
}
    
    
    
func applicationDidFinishLaunching(aNotification: NSNotification) {
    
}

//the copy to pasteboard method
func copyFromMenuBrain(sender: AnyObject) {
    
    //MenuBrain responds differently depending on the data selected. There are 6 possible cases:
    //1. ordinary string
    //2. string with annotation
    //3. URL that can be launched in a browser
    //4. other URL that cannot be launched (e.g., ftp)
    //5. other URL with annotation
    //6. web URL with annotation
    //URLs that can be launched should be. Other strings are copied to pasteboard. Annotations are ignored.
    
    //first, collect entire string that corresponds to menu selection
    var sentMenuItem: NSMenuItem = sender as! NSMenuItem
    var stringIndex = brainMenu.indexOfItem(sentMenuItem)
    var contents: NSString = brainArray[stringIndex] as! NSString
    print(contents)
    var contentString:NSString = ""
    var annotationString:NSString = ""

    
    //test for case 1, simple string
    if (!self.isURL(contents)) {
        //divide string by colon, if any are present
        var stringComponents = contents.componentsSeparatedByString(":");
        if (stringComponents.count == 1) {
            //we're done. this is a simple string.
            print("this is a simple string")
            contentString = contents
            let pasteboard = NSPasteboard.generalPasteboard()
            pasteboard.clearContents()
            pasteboard.setString(contentString as String, forType: NSPasteboardTypeString)
            return
        }
    }
    
    //test for case 2, string with annotation
    if (!self.isURL(contents)) {
        //divide string by colon, if any are present
        var stringComponents = contents.componentsSeparatedByString(":")
        if (stringComponents.count >= 2) {
        contentString = stringComponents[1]
    
        //rejoin non-annotation content divided by colons
        if (stringComponents.count > 2) {
            for var i = 2; i < stringComponents.count; i++ {
                contentString = "\(contentString):\(stringComponents[i])"
            }
        }
    
    //check contentString for URL
    
    //shave leading space
    let emptyPrefix = " "
    if (contentString.hasPrefix(emptyPrefix)) {
        print("shaving empty space")
        contentString = contentString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        print("shaved string is \(contentString)")
    }
    if (!self.isURL(contentString)) {
        print("this is a simple string with annotation")
        let pasteboard = NSPasteboard.generalPasteboard()
        pasteboard.clearContents()
        pasteboard.setString(contentString as String, forType: NSPasteboardTypeString)
        return
    }
    
    }
    
    
    }
    
    
    
    //test for case 4, non-launching URL
    if (self.isURL(contents)) {
        let ftpPrefix = "ftp://"
        if (contentString.hasPrefix(ftpPrefix)) {
            print("this is a non-launching URL")
            let pasteboard = NSPasteboard.generalPasteboard()
            pasteboard.clearContents()
            pasteboard.setString(contentString as String, forType: NSPasteboardTypeString)
            return
        }
    }
    
    //test for case 5, non-launching URL with annotation
    if (self.isURL(contents)) {
    //divide string by colon, if any are present
    var stringComponents = contents.componentsSeparatedByString(":")
    if (stringComponents.count >= 2) {
        contentString = stringComponents[1]
    
        //rejoin non-annotation content divided by colons
        if (stringComponents.count > 2) {
            for var i = 2; i < stringComponents.count; i++ {
                contentString = "\(contentString):\(stringComponents[i])"
            }
        }
    
    }
    
    //check contentString for URL
    
    //shave leading space
    let emptyPrefix = " "
    if (contentString.hasPrefix(emptyPrefix)) {
        print("shaving empty space")
        contentString = contentString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        print("shaved string is \(contentString)")
    }
        
    if (self.isURL(contentString)) {
    //check for FTP address
        let ftpPrefix = "ftp://"
        if (contentString.hasPrefix(ftpPrefix)) {
            print("this is an FTP address with annoation")
            let pasteboard = NSPasteboard.generalPasteboard()
            pasteboard.clearContents()
            pasteboard.setString(contentString as String, forType: NSPasteboardTypeString)
            return
        } else {
            self.sendURL(contentString)
            return
        }
    
    }
    }
    
    //test for case 6, web URL with annotation
    if (self.isURL(contents)) {
    //divide string by colon, if any are present
        var stringComponents = contents.componentsSeparatedByString(":")
        if (stringComponents.count >= 2) {
            contentString = stringComponents[1]
    
            //rejoin non-annotation content divided by colons
            if (stringComponents.count > 2) {
                for var i = 2; i < stringComponents.count; i++ {
                    contentString = "\(contentString):\(stringComponents[i])"
                }
            }
    
    }
    
    //check contentString for URL
    
    ///shave leading space
    let emptyPrefix = " "
    if (contentString.hasPrefix(emptyPrefix)) {
        print("shaving empty space")
        contentString = contentString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        print("shaved string is \(contentString)")
    }
    
    if (self.isURL(contentString)) {
        //rule out FTP addresses
        let ftpPrefix = "ftp://"
        if (!contentString.hasPrefix(ftpPrefix)) {
            self.sendURL(contentString)
            return
        }
    }
    }
    
    //that leaves case 3, simple web URL
    if (self.isURL(contents)) {
        //rule out FTP addresses
        let ftpPrefix = "ftp://"
        if (!contentString.hasPrefix(ftpPrefix)) {
            self.sendURL(contentString)
            return
        }
    
    }
    
    
    
    
    }

func isURL(contents:AnyObject) -> Bool {

    //account for URLs containing directories
    var stringComponents = contents.componentsSeparatedByString("/")
    var stringToCheck = ""
    stringToCheck = stringComponents[0]
    if (self.isURLStringCheck(stringToCheck)) {
    return true
    }
    if (stringComponents.count >= 2) {
    stringToCheck = stringComponents[1]
    if self.isURLStringCheck(stringToCheck) == true {
        return true
    }
    
    }
    if (stringComponents.count >= 3) {
    stringToCheck = stringComponents[2]
    if self.isURLStringCheck(stringToCheck) == true {
        return true
    }
    
    }
    return false
    
}

func sendURL(var contents:NSString) {

    print("sendURL received: \(contents)")
    
    if contents.hasPrefix("//") {
        contents = contents.substringWithRange(NSMakeRange(2, contents.length - 2))
    }
    if contents.hasPrefix("/") {
        contents = contents.substringWithRange(NSMakeRange(1, contents.length - 1))
    }
    
    if contents.hasPrefix("//") {
        contents = contents.substringWithRange(NSMakeRange(8, contents.length - 8))
    }
    
    var URL:NSURL = NSURL(string: "")!
    
    if contents.hasPrefix("http://") {
        print("this is a web URL: \(contents)")
        URL = NSURL(string:contents as String)!
    } else {
        var validURL:NSString = "http://\(contents)"
        print("made valid URL\(validURL)")
        URL = NSURL(string: validURL as String)!

    }
    
    if NSEventModifierFlags.contains(.CommandKeyMask) {
    
    //if (optionKeyIsDown) {
    
        // Copy to clipboard
        let pasteboard = NSPasteboard.generalPasteboard()
        pasteboard.clearContents()
        pasteboard.setString(URL as String, forType: NSPasteboardTypeString)
    }
    else {
    // Send the url
    [[NSWorkspace sharedWorkspace] openURL:URL];
    }
}
    
    
func isURLStringCheck(contents: NSString) -> Bool {
    //first, test if it's an email address
    let emailRegEx =
    "(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    "z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    "9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
    
    let regExPredicate:NSPredicate = NSPredicate(format: "self matches %@", emailRegEx)
    
    let isEmailAddress:Bool = regExPredicate.evaluateWithObject(contents)
    
    if (isEmailAddress) {
        return false
        //next, test for common URL prefixes and TLDs
    } else if (contents.hasPrefix("http://")) {
        return true
    } else if (contents.hasPrefix("https://")) {
        return true
    } else if (contents.hasPrefix("ftp://")) {
        return true
    } else if (contents.hasPrefix("www.")) {
        return true
    } else if (contents.hasSuffix(".com")) {
        return true
    } else if (contents.hasSuffix(".edu")) {
        return true
    } else if (contents.hasSuffix(".org")) {
        return true
    } else if (contents.hasSuffix(".net")) {
        return true
    } else if (contents.hasSuffix(".biz")) {
        return true
    } else if (contents.hasSuffix(".info")) {
        return true
    } else if (contents.hasSuffix(".name")) {
        return true
    } else if (contents.hasSuffix(".pro")) {
        return true
    } else if (contents.hasSuffix(".gov")) {
        return true
    } else if (contents.hasSuffix(".mil")) {
        return true
    } else if (contents.hasSuffix(".co.uk")) {
        return true
    } else if (contents.hasSuffix(".us")) {
        return true
    } else {
        return false
    }
}
    
    
override func awakeFromNib() {
    insertionPoint = 0
    self.inputField.stringValue = ""
    
    //Create the NSStatusBar and set its length
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSSquareStatusItemLength)
    
    //Sets the images in our NSStatusItem
    statusItem.image = NSImage(named: "menubarIcon")
    statusItem.alternateImage = NSImage(named: "menubarIconActive")

    
    //Tells the NSStatusItem what menu to load
    statusItem.menu = brainMenu
    //Sets the tooptip for our item
    statusItem.toolTip = "MenuBrain"
    //Enables highlighting
    statusItem.highlightMode = true
    
    //Register for drag and drop
    var registeredTypes:[String] = [NSStringPboardType]
    self.brainTable.registerForDraggedTypes(registeredTypes)
    
    //Add the Edit... item
    let editMenuItem = NSMenuItem(title: "Edit", action: Selector(showEditWindow()), keyEquivalent: "")
    brainMenu.addItem(editMenuItem)
    editMenuItem.target = self
    editMenuItem.enabled = true
    
    //Add the Quit MenuBrain item
    let quitMenuItem = NSMenuItem(title: "Quit MenuBrain", action: Selector("Quit:"), keyEquivalent: "")
    brainMenu.addItem(quitMenuItem)
    quitMenuItem.target = NSApp
    quitMenuItem.enabled = true
    
    //Determine if a MenuBrain file already exists
    let fileManager = NSFileManager.defaultManager()
    var folder: NSString = "~/Library/Application Support/MenuBrain/"
    folder = folder.stringByExpandingTildeInPath
    let fileName = "MenuBrain.menubraindata"
    let filePath = folder.stringByAppendingPathComponent(fileName as String)
    if fileManager.fileExistsAtPath(filePath) {
        print("Looks like there's a datafile to load.")
        firstRun = false
        self.loadDataFromDisk()
        self.rebuildMenuAfterLoad()
    } else {
        print("No datafile found.")
        //firstRun = true
        //If the user is new to MenuBrain, give her a little hint
        print("trying to rebuild Get Started menu item.")
        let getStartedMenuItem = NSMenuItem(title: "Click on Edit... to get started", action: Selector(), keyEquivalent: "")
        brainMenu.insertItem(getStartedMenuItem, atIndex: 0)
        getStartedMenuItem.target = self
        getStartedMenuItem.enabled = false
    }
    
    
    self.refreshAll()
    
    }
    
func showEditWindow() {
    NSApplication.sharedApplication().activateIgnoringOtherApps(true)
    self.menuBrainWindow.makeKeyAndOrderFront(self)
    self.inputField.selectText(self)
    self.inputField.currentEditor()?.selectedRange = NSMakeRange(0, self.inputField.stringValue.characters.count)
    
    }
    
    
func addMenuBrainMenuItem(newString:NSString, rowIndex:Int) {
        
    var menuString:NSString = self.truncateMenuTitle(newString)
    var newMenuItem = NSMenuItem(title: menuString as String, action: Selector("copy:"), keyEquivalent: "")
    brainMenu.insertItem(newMenuItem, atIndex:rowIndex)

    newMenuItem.target = self
    newMenuItem.enabled = true
}
    
    
    

    
    //After any edit, update the menu, table view, and save the data
    
func refreshAll() {
    self.saveDataToDisk()
    brainTable.reloadData()
    }
    
    //Weird code that makes the table view work with NSMutableArray
    
//    - (int)numberOfRowsInTableView:(NSTableView *)tv
//    {
//    return [stringArray count];
//    }
//    
//    - (id)tableView:(NSTableView *)tv
//    objectValueForTableColumn:(NSTableColumn *)tableColumn
//    row:(int)row
//    {
//    NSString *v = [stringArray objectAtIndex:row];
//    return v;
//    }
//    
//    
//    
//    - (void)tableView:(NSTableView *)aTableView
//    setObjectValue:(id)anObject
//    forTableColumn:(NSTableColumn *)aTableColumn
//    row:(NSInteger)rowIndex
//    {
//    
//    [stringArray replaceObjectAtIndex:rowIndex withObject:anObject];
//    [brainMenu removeItemAtIndex:rowIndex];
//    
//    [self addMenuBrainMenuItem:anObject atIndex:rowIndex];
//    
//    
//    [self refreshAll];
//    
//    }
    
    
func tableViewSelectionDidChange(notification: NSNotification) {
    let row:Int = brainTable.selectedRow

    if (row == -1) {
    NSLog(@"selection changed to row %i", row);
    return;
    }
    }
    
    //Drag and Drop
    
    static int _moveRow = 0;
    
    - (BOOL)tableView:(NSTableView *)tv writeRows:(NSArray*)rows toPasteboard:(NSPasteboard*)pboard
    {
    int count = [stringArray count];
    int rowCount = [rows count];
    if (count < 2) return NO;
    
    [pboard declareTypes:[NSArray arrayWithObject:GifInfoPasteBoard] owner:self];
    [pboard setPropertyList:rows forType:GifInfoPasteBoard];
    _moveRow = [[rows objectAtIndex:0]intValue];
    return YES;
    }
    
    - (unsigned int)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op
    {
    if (row != _moveRow) {
    if (op==NSTableViewDropAbove) {
    return NSDragOperationEvery;
    }
    return NSDragOperationNone;
    }
    return NSDragOperationNone;
    }
    
    - (BOOL)tableView:(NSTableView*)tv acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)op
    {
    BOOL result = (unsigned char) [self tableView:tableView didDepositRow:_moveRow at:(int)row];
    [self refreshAll];
    return result;
    }
    
    // here we actually do the management of the data model:
    
    - (BOOL)tableView:(NSTableView *)tv didDepositRow:(int)rowToMove at:(int)newPosition
    {
    if (rowToMove != -1 && newPosition != -1) {
    id object = [stringArray objectAtIndex:rowToMove];
    if (newPosition < [stringArray count] - 1) {
    [stringArray removeObjectAtIndex:rowToMove];
    [stringArray insertObject:object atIndex:newPosition];
    [brainMenu removeItemAtIndex:rowToMove];
    
    [self addMenuBrainMenuItem:object atIndex:newPosition];
    
    
    } else {
    [stringArray removeObjectAtIndex:rowToMove];
    [stringArray addObject:object];
    [brainMenu removeItemAtIndex:rowToMove];
    
    [self addMenuBrainMenuItem:object atIndex:[stringArray count] - 1];
    
    
    }
    return YES;    // ie reload
    }
    return NO;
    }
    
    //Saving and Loading
    
    - (NSString *) pathForDataFile
    {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *folder = @"~/Library/Application Support/MenuBrain/";
    folder = [folder stringByExpandingTildeInPath];
    if ([fileManager fileExistsAtPath: folder] == NO) {
    [fileManager createDirectoryAtPath: folder attributes: nil];
    }
    NSString *fileName = @"MenuBrain.menubraindata";
    return [folder stringByAppendingPathComponent: fileName];
    }
    
    - (void) encodeWithCoder: (NSCoder *)coder
    {
    [coder encodeObject:stringArray forKey:@"menubraindata"];
    }
    
    - (void)saveDataToDisk {
    NSString * path = [self pathForDataFile];
    //NSMutableDictionary * rootObject;
    //rootObject = [NSMutableDictionary dictionary];
    //[rootObject setValue: stringArray forKey:@"menubraindata"];
    [NSKeyedArchiver archiveRootObject: stringArray toFile: path];
    }
    
    - (void)loadDataFromDisk {
    if (firstRun == NO) {
    NSString *path = [self pathForDataFile];
    NSMutableArray *rootObject;
    rootObject = [[NSMutableArray alloc] init];
    rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    stringArray = [[NSMutableArray alloc] init];
    //stringArray = [[stringArray arrayByAddingObjectsFromArray:rootObject]retain];
    int i;
    int rootObjectRowCount = [rootObject count];
    for (i=0; i < rootObjectRowCount; i++) {
    [stringArray insertObject:[rootObject objectAtIndex:i] atIndex:i];
    }
    //NSLog(@"first line is %@",[stringArray objectAtIndex:0]);
    int rowCount = [stringArray count];
    
    NSLog(@"number of rows to rebuild: %i", rowCount);
    }
    
    
    }
    
    - (void)rebuildMenuAfterLoad {
    int rowCount = [stringArray count];
    int i;
    for (i=0; i < rowCount; i++) {
    //Add string to status menu
    
    NSString *newString = @"";
    newString = [stringArray objectAtIndex:i];
    
    [self addMenuBrainMenuItem:newString atIndex:insertionPoint];
    
    
    
    insertionPoint++;
    
    
    }
    [self refreshAll];
    }
    
    - (NSString *)truncateMenuTitle:(id)contents {
    
    NSArray *titleComponents = [contents componentsSeparatedByString:@":"];
    
    NSString *titleFrontEnd = @"";
    NSString *titleBackEnd = @"";
    NSString *titleBackEndOne = @"";
    NSString *titleBackEndTwo = @"";
    NSString *finalBackEnd = @"";
    NSString *divider = @"";
    
    //URLs aren't annotations
    if ([self isURL:contents] == YES) {
    titleBackEnd = contents;
    } else {
    //is this an annotation?
    if ([titleComponents count] >= 2) {
    divider = @":",
    titleFrontEnd = [titleComponents objectAtIndex:0];
    titleBackEnd = [titleComponents objectAtIndex:1];
    if ([titleComponents count] > 2) {
				int i;
				for (i=2;i<[titleComponents count];i++) {
    titleBackEnd = [NSString stringWithFormat:@"%@:%@", titleBackEnd, [titleComponents objectAtIndex:i]];
				}
    }
    } else {
    titleBackEnd = [titleComponents objectAtIndex:0];
    }
    }
    
    
    
    //split the non-annotation into two segments and connect with ellipsis
    int stringLength = [titleBackEnd length];
    
    if (stringLength > 60) {
    titleBackEndOne = [titleBackEnd substringWithRange:NSMakeRange(0, 30)];
    titleBackEndTwo = [titleBackEnd substringWithRange:NSMakeRange(stringLength - 30, 30)];
    finalBackEnd = [NSString stringWithFormat:@"%@ … %@", titleBackEndOne, titleBackEndTwo];
    } else {
    finalBackEnd = titleBackEnd;
    }
    
    
    
    NSString *completeTitle = [NSString stringWithFormat:@"%@%@%@", titleFrontEnd, divider, finalBackEnd];
    
    return completeTitle;
    }
    
    //integrate with Services
    
    - (void)applicationDidFinishLaunching:(NSNotification *)notification {
    // To get service requests to go to the controller...
    [NSApp setServicesProvider:self];
    }
    
    - (void)readSelectionFromPasteboard:(NSPasteboard *)pboard 
    userData:(NSString *)data error:(NSString **)error {
    NSArray *types = [pboard types];
    NSString *selectionString = @"";
    
    if ([types containsObject:NSStringPboardType]){
    selectionString = [pboard stringForType:NSStringPboardType];
    NSLog(@"%@",selectionString);
    [self addStringViaService:selectionString];
    return;
    } else {
    return;
    }
    
    
    }
    
    - (void)addStringViaService:(id)contents {
    
    [self showEditWindow];
    [inputField setStringValue:contents];
    
    }

}

