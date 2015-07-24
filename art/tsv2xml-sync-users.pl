#
# Educational Online Test Delivery System
# Copyright (c) 2015 American Institutes for Research
# 
# Distributed under the AIR Open Source License, Version 1.0
# See accompanying file AIR-License-1_0.txt or at
# http://www.smarterapp.org/documents/American_Institutes_for_Research_Open_Source_Software_License.pdf
#

use IO::File;
use XML::Writer;
use Getopt::Long;

# get the command line options
my $InputFile;
GetOptions( 
	"infile=s" => \$InputFile,
)
or die("Error in command line arguments\n");
open( INPUTFILE, "<", $InputFile ) or die( "Unable to open input file \"$InputFile\"\n" );

my $del_output = new IO::File(">del_sso_users.xml");
my $delusers = XML::Writer->new( OUTPUT => $del_output, UNSAFE => 1 ); # DELETE users file
$delusers->raw( $XmlHeader );

$delusers->startTag( "Users" );
$delusers->raw       ( "\n" );  

my $First = 1;
# foreach user
while( <INPUTFILE> )
{
    if( !$First ) # skip the header row
    {
		chomp;
		$delusers->raw       ( "  " );
		$delusers->startTag  ( "User", "Action" => "SYNC" );
		$delusers->raw       ( "\n" );
		/^([0-9a-f]*),/;
		print( $1, "\n" );
		$delusers->raw       ( "    " );
		$delusers->startTag  ( "UUID" );
		$delusers->characters( $1 );
		$delusers->endTag    ( "UUID" ); 
		$delusers->raw       ( "\n" );

		$delusers->raw       ( "  " );
		$delusers->endTag    ( "User" );  
		$delusers->raw       ( "\n" );
	}
	$First = 0;
}

$delusers->endTag( "Users" );  
$delusers->raw       ( "\n" );  
$delusers->end();

close( INPUTFILE );
