/*******************************************************************************
 * Copyright (c) 2012, Jean-David Gadina <macmade@eosgarden.com>
 * Distributed under the Boost Software License, Version 1.0.
 * 
 * Boost Software License - Version 1.0 - August 17th, 2003
 * 
 * Permission is hereby granted, free of charge, to any person or organization
 * obtaining a copy of the software and accompanying documentation covered by
 * this license (the "Software") to use, reproduce, display, distribute,
 * execute, and transmit the Software, and to prepare derivative works of the
 * Software, and to permit third-parties to whom the Software is furnished to
 * do so, all subject to the following:
 * 
 * The copyright notices in the Software and this entire statement, including
 * the above license grant, this restriction and the following disclaimer,
 * must be included in all copies of the Software, in whole or in part, and
 * all derivative works of the Software, unless such copies or derivative
 * works are solely in the form of machine-executable object code generated by
 * a source language processor.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
 * SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
 * FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 ******************************************************************************/

/* $Id$ */

/*!
 * @file            ...
 * @author          Jean-David Gadina <macmade@eosgarden>
 * @copyright       (c) 2012, eosgarden
 * @abstract        ...
 */

#import "EOSFile.h"
#import "EOSFile+Private.h"

@implementation EOSFile

@synthesize url                         = _url;
@synthesize path                        = _path;
@synthesize type                        = _type;
@synthesize flags                       = _flags;
@synthesize immutable                   = _immutable;
@synthesize appendOnly                  = _appendOnly;
@synthesize busy                        = _busy;
@synthesize readable                    = _readable;
@synthesize writeable                   = _writeable;
@synthesize executable                  = _executable;
@synthesize extensionHidden             = _extensionHidden;
@synthesize systemNumber                = _systemNumber;
@synthesize systemFileNumber            = _systemFileNumber;
@synthesize deviceIdentifier            = _deviceIdentifier;
@synthesize HFSCreatorCode              = _HFSCreatorCode;
@synthesize HFSTypeCode                 = _HFSTypeCode;
@synthesize bytes                       = _bytes;
@synthesize kiloBytes                   = _kiloBytes;
@synthesize megaBytes                   = _megaBytes;
@synthesize gigaBytes                   = _gigaBytes;
@synthesize teraBytes                   = _teraBytes;
@synthesize humanReadableSize           = _humanReadableSize;
@synthesize referenceCount              = _referenceCount;
@synthesize ownerID                     = _ownerID;
@synthesize groupID                     = _groupID;
@synthesize owner                       = _owner;
@synthesize group                       = _group;
@synthesize permissions                 = _permissions;
@synthesize octalPermissions            = _octalPermissions;
@synthesize humanReadablePermissions    = _humanReadablePermissions;
@synthesize name                        = _name;
@synthesize displayName                 = _displayName;
@synthesize extension                   = _extension;
@synthesize creationDate                = _creationDate;
@synthesize modificationDate            = _modificationDate;

+ ( EOSFile * )fileWithPath: ( NSString * )path
{
    EOSFile * file;
    
    file = [ [ EOSFile alloc ] initWithPath: path ];
    
    return [ file autorelease ];
}

+ ( EOSFile * )fileWithURL: ( NSURL * )url
{
    EOSFile * file;
    
    file = [ [ EOSFile alloc ] initWithURL: url ];
    
    return [ file autorelease ];
}

+ ( EOSFile * )addNewFileWithPath: ( NSString * )path data: ( NSData * )data
{
    if( [ [ NSFileManager defaultManager ] createFileAtPath: path contents: data attributes: nil ] )
    {
        return [ EOSFile fileWithPath: path ];
    }
    
    return nil;
}

+ ( EOSFile * )addNewFileWithURL: ( NSURL * )url data: ( NSData * )data
{
    if( [ [ NSFileManager defaultManager ] createFileAtPath: [ url path ] contents: data attributes: nil ] )
    {
        return [ EOSFile fileWithPath: [ url path ] ];
    }
    
    return nil;
}

- ( id )initWithPath: ( NSString * )path
{
    if( ( self = [ self initWithURL: [ NSURL fileURLWithPath: path ] ] ) )
    {}
    
    return self;
}

- ( id )initWithURL: ( NSURL * )url
{
    if( ( self = [ self init ] ) )
    {
        if( [ [ NSFileManager defaultManager ] fileExistsAtPath: [ url path ] ] == NO )
        {
            [ self release ];
            
            return nil;
        }
        
        _url  = [ url copy ];
        _path = [ [ url path ] copy ];
        
        if( [ self getFileInformations ] == NO )
        {
            [ self release ];
            
            return nil;
        }
        
        if( _type == EOSFileTypeDirectory && [ _path hasSuffix: @"/" ] == NO )
        {
            [ _path autorelease ];
            
            _path = [ [ _path stringByAppendingString: @"/" ] copy ];
        }
    }
    
    return self;
}

- ( void )dealloc
{
    [ _url                      release ];
    [ _path                     release ];
    [ _humanReadableSize        release ];
    [ _owner                    release ];
    [ _group                    release ];
    [ _humanReadablePermissions release ];
    [ _name                     release ];
    [ _displayName              release ];
    [ _extension                release ];
    [ _creationDate             release ];
    [ _modificationDate         release ];
    
    [ super dealloc ];
}

- ( NSFileHandle * )fileHandleForReading
{
    return [ NSFileHandle fileHandleForReadingAtPath: _path ];
}

- ( NSFileHandle * )fileHandleForWriting
{
    return [ NSFileHandle fileHandleForWritingAtPath: _path ];
}

- ( NSFileHandle * )fileHandleForUpdating
{
    return [ NSFileHandle fileHandleForUpdatingAtPath: _path ];
}

- ( NSString * )creationDateWithFormat: ( NSString * )format
{
    NSString        * date;
    NSDateFormatter * formatter;
    
    formatter               = [ NSDateFormatter new ];
    formatter.dateFormat    = format;
    date                    = [ formatter stringFromDate: _creationDate ];
    
    [ formatter release ];
    
    return date;
}

- ( NSString * )modificationDateWithFormat: ( NSString * )format
{
    NSString        * date;
    NSDateFormatter * formatter;
    
    formatter               = [ NSDateFormatter new ];
    formatter.dateFormat    = format;
    date                    = [ formatter stringFromDate: _modificationDate ];
    
    [ formatter release ];
    
    return date;
}

- ( NSData * )data
{
    NSData  * data;
    NSError * error;
    
    error = nil;
    data  = [ [ NSFileManager defaultManager ] contentsAtPath: _path ];
    
    return data;
}

- ( BOOL )writeData: ( NSData * )data
{
    return [ [ NSFileManager defaultManager ] createFileAtPath: _path contents: data attributes: nil ];
}

- ( BOOL )delete: ( NSError ** )error
{
    if( error != NULL )
    {
        *( error ) = nil;
    }
    
    [ [ NSFileManager defaultManager ] removeItemAtURL: _url error: error ];
    
    return error == nil;
}

@end
