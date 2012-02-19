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

#import "EOSFTPServerDataConnection.h"
#import "EOSFTPServerDataConnection+Private.h"
#import "EOSFTPServerDataConnection+AsyncSocketDelegate.h"
#import "EOSFTPServerConnection.h"
#import "AsyncSocket.h"

@implementation EOSFTPServerDataConnection

@synthesize receivedData    = _receivedData;
@synthesize connectionState = _connectionState;
@synthesize delegate        = _delegate;

- ( id )initWithSocket: ( AsyncSocket * )socket connection: ( EOSFTPServerConnection * )connection queuedData: ( NSMutableArray * )queuedData delegate: ( id < EOSFTPServerDataConnectionDelegate > )delegate
{
    if( ( self = [ self init ] ) )
    {
        _dataSocket    = [ socket retain ];
        _ftpConnection = connection;
        _delegate      = delegate;
        
        [ _dataSocket setDelegate: self ];
        
        if( [ queuedData count ] )
        {
            EOS_FTP_DEBUG( @"Writing queued data" );
            
            [ self writeQueuedData: queuedData ];
            [ queuedData removeAllObjects ];
        }
        
        [ _dataSocket readDataWithTimeout: EOS_FTP_SERVER_READ_TIMEOUT tag: EOS_FTP_SERVER_CLIENT_REQUEST ];
        
        _dataListeningSocket = nil;
        _receivedData        = nil;
        _connectionState     = EOSFTPServerConnectionStateClientQuiet;
    }
    
    return self;
}

- ( void )writeString: ( NSString * )str
{
    NSMutableData * data;
    
    EOS_FTP_DEBUG( @"Writing string" );
    
    data = [ [ str dataUsingEncoding: NSUTF8StringEncoding ] mutableCopy ];
    
    [ data appendData: [ AsyncSocket CRLFData ] ];									
    [ _dataSocket writeData: data withTimeout: EOS_FTP_SERVER_READ_TIMEOUT tag: EOS_FTP_SERVER_CLIENT_REQUEST ];		
    [ _dataSocket readDataWithTimeout: EOS_FTP_SERVER_READ_TIMEOUT tag: EOS_FTP_SERVER_CLIENT_REQUEST ];
    [ data autorelease ];
}

- ( void )writeData: ( NSMutableData * )data
{
    EOS_FTP_DEBUG( @"Writing data" );
    
    _connectionState = EOSFTPServerConnectionStateClientReceiving;
    
    [ _dataSocket writeData: data withTimeout: EOS_FTP_SERVER_READ_TIMEOUT tag: EOS_FTP_SERVER_CLIENT_REQUEST ];	
    [ _dataSocket readDataWithTimeout: EOS_FTP_SERVER_READ_TIMEOUT tag: EOS_FTP_SERVER_CLIENT_REQUEST ];
}

- ( void )closeConnection
{
    EOS_FTP_DEBUG( @"Closing connection" );
    
    [ _dataSocket disconnect ];
}

@end
