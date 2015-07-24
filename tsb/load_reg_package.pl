#=================================================================================
#=================================================================================
#=================================================================================
#
# Educational Online Test Delivery System
# Copyright (c) 2015 American Institutes for Research
# 
# Distributed under the AIR Open Source License, Version 1.0
# See accompanying file AIR-License-1_0.txt or at
# http://www.smarterapp.org/documents/American_Institutes_for_Research_Open_Source_Software_License.pdf
# 
# Script: load_reg_package.pl
# Author: David Lopez de Quintana
#
# The purpose of this script is to load one or more registration test packages
# into a Test Spec Bank Bank (TSB). Once loaded into a TSB, the test packages
# can be selected into an instance of ART for student registration.
#
#=================================================================================
#=================================================================================
#=================================================================================

use Getopt::Long;
use File::Find;
use Compress::Zlib;
use MIME::Base64;
use JSON;
use Data::Dumper;
use URI::Escape;
use strict;

#=================================================================================
# systemwide constants

my $TRUE = 1;
my $FALSE = 0;

#=================================================================================
# obtain configuration from config file

# configuration will be stored in a config hash
my %Configuration;
$Configuration{ 'Debug'                  } = -1;
$Configuration{ 'OpenAmUri'              } = -1;
$Configuration{ 'OpenAmClientSecret'     } = -1;
$Configuration{ 'ProgramMgmtUri'         } = -1;
$Configuration{ 'ProgramMgmtTenant'      } = -1;
$Configuration{ 'ProgramMgmtTenantLevel' } = -1;
$Configuration{ 'ProgManUserId'          } = -1;
$Configuration{ 'ProgManPassword'        } = -1;
$Configuration{ 'TestSpecBankUri'        } = -1;
$Configuration{ 'TestSpecBankUserId'     } = -1;
$Configuration{ 'TestSpecBankPassword'   } = -1;

# read the configuraiton file
my $ConfigFilename = $0 . ".cfg";
open( CONFIGFILE, "<", $ConfigFilename ) or 
    die( "Unable to open configuration file \"$ConfigFilename\"\n" );
while( <CONFIGFILE> )
{
	chomp;
	/(\w*)\s*=(.*)/;
	$Configuration{ $1 } = $2;
}
close( CONFIGFILE );

# ensure that all required configuration has been loaded
my $Key;
my $Value;
while( ( $Key, $Value ) = each( %Configuration ) ) 
{
    if( $Value eq "-1" )
	{
		die( "Config key \"$Key\" not found in config file \"$ConfigFilename\"\n" );
	}
}

my $Debug = $Configuration{ 'Debug' };

#=================================================================================
# get the command line parameters

print( "\n" ) if $Debug;

# get the command line options
my $FilePathParam;
my $ExecuteParam;
GetOptions( 
	"path=s" => \$FilePathParam,
	"exec"   => \$ExecuteParam,
)
or die("Usage is load_reg_package.pl --path=<test package file name or directory with test packages in it>\n");

# print some help text if no parameter is provided
if( $FilePathParam eq "" )
{
	print( 
"
AIR Registration Publication Uploader Script

The purpose of this script is to load a registration test package or set of packages
into a Test Spec Bank Bank. Once loaded into a Test Spec Bank, the test packages
can be selected into an instance of ART for student registration. This script performs
the following steps:

1. Obtains a filename of a test package a directory containing test packages from the
   path command line switch provided by the user.
2. Obtains an OAuth token from the OpenAM Single Sign On using the configured 
   user credentials on behalf of an administrative user with access to Program
   Management for extracting the tenant ID
3. Obtains the tenant ID of the configured tenant from Program Management
4. Obtains an OAuth token on behalf of a user with admin privileges in Test Spec Bank
5. Processes one or more registration test package XMLs
   a. Analyzes and extract required attributes from the registration test package
   b. Compresses and base 64 encodes the test package
   c. Inserts the test package into the Test Spec Bank

Usage: load_reg_package.pl 
    --path=<test package file name or directory with test packages in it> 
	--exec\n

Use --exec to actually load the test into the test spec bank. If --exec is not used, 
all steps will be performed except actually inserting tests into the Test Spec Bank.
Skip this switch at first and observe the output of this script and ensure that all
processing is as expected before committing to loading a test or directory of tests.

This script requires a configuration file located in the same folder as the script 
with the same name as the script with \".cfg\" appended to it. The configuration items 
are as follows:

Debug: set to 1 for full verbose information written to standard output
OpenAmUri: the base URI of OpenAM to obtain OAuth tokens
OpenAmClientSecret: a string that matches the OpenAM configuration for the OAuth client
ProgramMgmtUri: the base URI of the Program Management component for the tenant ID
ProgramMgmtTenant: Tests loaded into Test Spec Bank will be under this tenant
ProgramMgmtTenantLevel: the level of the above tenant (usually STATE)
ProgManUserId: the ID of a user with an Administrator role associated with CLIENT
ProgManPassword: the password of the above user
TestSpecBankUri: the URI of the Test Spec Bank used to load tests
TestSpecBankUserId: the ID of a user with (a) a role such Test Authoring Administrator
   that is mapped to both TestSpecBank permissions (Test Spec Admin and Test Spec Read)
   and (b) associated with the same tenant as the ProgramMgmtTenant config above
TestSpecBankPassword: the password of the above user
"
	);
	exit( 0 );
}

print( "Path command line parameter = $FilePathParam\n" ) if $Debug;

# ensure the command line parameter is either a file or directory
# terminate execution if it is neither
my $ProcessingSingleFile = ( -f $FilePathParam );
my $ProcessingDirectory  = ( -d $FilePathParam );
if( !( $ProcessingSingleFile | $ProcessingDirectory ) )
{
	print( "Path must be a file or a directory\n" );
	exit( 0 );
}

#=================================================================================
# Obtain the OAuth token for ProgMan from OpenAM

print( "Getting Program Management access token from OpenAM\n" );

# build the OAuth token URL
my $OAuthAccessUrl = "$Configuration{ 'OpenAmUri' }/auth/oauth2/access_token?realm=/sbac";
my $OAuthParams    = "grant_type=password&client_id=pm&client_secret=$Configuration{ 'OpenAmClientSecret' }&username=$Configuration{ 'ProgManUserId' }&password=$Configuration{ 'ProgManPassword' }";
my $OAuthTokenUrl  = "curl -s --insecure -3 --data \"$OAuthParams\" --header \"application/x-www-form-urlencoded\" $OAuthAccessUrl";
print( "OAuthAccessUrl = \"$OAuthAccessUrl\"\n" ) if $Debug;
print( "OAuthParams = \"$OAuthParams\"\n" ) if $Debug;
print( "OAuth Token URL is \"$OAuthTokenUrl\"\n" ) if $Debug;

# call OpenAM and obtain a token
print( "Calling OpenAM to get OAuth token for Program Management\n" ) if $Debug;
my $TokenJson = from_json( `$OAuthTokenUrl` );
print( "JSON returned from OpenAM for obtaining admin user OAuth token for Program Management:\n" ) if $Debug;
print Dumper( $TokenJson )  if $Debug;

# extract the access token
my $ProgManAccessToken = $TokenJson->{ 'access_token' };
print( "ProgManAccessToken = \"$ProgManAccessToken\"\n" ) if $Debug;

#=================================================================================
# Obtain the tenant ID from Program Management

print( "Getting tenant ID from Program Management\n" );

# build the Program Management URL
my $ProgramMgmtUrl = "$Configuration{ 'ProgramMgmtUri' }/rest/tenant?name=$Configuration{ 'ProgramMgmtTenant' }&type=$Configuration{ 'ProgramMgmtTenantLevel' }";
my $ProgramMgmtParams = "Authorization: Bearer $ProgManAccessToken";
my $TenantIdUrl = "curl -s -G --insecure -3 --header \"$ProgramMgmtParams\" $ProgramMgmtUrl";

print( "ProgramMgmtUrl = \"$ProgramMgmtUrl\"\n") if $Debug;
print( "ProgramMgmtParams = \"$ProgramMgmtParams\"\n" ) if $Debug;
print( "TenantIdUrl = \"$TenantIdUrl\"\n" ) if $Debug;

# call Program Management and get the tenant information
print( "Calling Program Management to get tenant ID\n" ) if $Debug;
my $TenantIdJson = from_json( `$TenantIdUrl` );
print( "JSON returned from Program Management:\n" ) if $Debug;
print Dumper( $TenantIdJson )  if $Debug;

# determine how many tenants were returned by this call
my $TenantId;
my $TenantFound = $FALSE;
my $NumberOfTenants = $TenantIdJson->{ 'returnCount' };
print( "NumberOfTenants = \"$NumberOfTenants\"\n" ) if $Debug;

#find the correct tenant
print( "Searching return JSON from Program Management for the correct tenant\n" ) if $Debug;
for( my $Index = 0; $Index < $NumberOfTenants; $Index++ )
{
	print( "Tenant name = \"$TenantIdJson->{'searchResults'}[ $Index ]{ 'name' }\" type = \"$TenantIdJson->{'searchResults'}[ $Index ]{ 'type' }\"\n" ) if $Debug;
	if( $TenantIdJson->{'searchResults'}[ $Index ]{ 'name' } eq $Configuration{ 'ProgramMgmtTenant' } && 
	    $TenantIdJson->{'searchResults'}[ $Index ]{ 'type' } eq $Configuration{ 'ProgramMgmtTenantLevel' } )
	{
		print( "Found tenant \"$TenantIdJson->{'searchResults'}[ $Index ]{ 'name' }\" at level \"$TenantIdJson->{'searchResults'}[ $Index ]{ 'type' }\"\n" ) if $Debug;
		$TenantId = $TenantIdJson->{'searchResults'}[ $Index ]{'id'};
		$TenantFound = $TRUE;
		last();
	}
}

print( "TenantId = \"$TenantId\"\n" ) if $Debug;
if( !$TenantFound ) { die( "Unable to find tenant \"$Configuration{ 'ProgramMgmtTenant' }\" at level \"$Configuration{ 'ProgramMgmtTenantLevel' }\"\n" ); }

#=================================================================================
# Obtain the OAuth token for Test Spec Bank from OpenAM

print( "Getting Test Spec Bank access token from OpenAM\n" );

# build the OAuth token URL
$OAuthParams    = "grant_type=password&client_id=pm&client_secret=$Configuration{ 'OpenAmClientSecret' }&username=$Configuration{ 'TestSpecBankUserId' }&password=$Configuration{ 'TestSpecBankPassword' }";
$OAuthTokenUrl  = "curl -s --insecure -3 --data \"$OAuthParams\" $OAuthAccessUrl --header \"application/x-www-form-urlencoded\"";
print( "OAuthAccessUrl = \"$OAuthAccessUrl\"\n" ) if $Debug;
print( "OAuth Token URL is \"$OAuthTokenUrl\"\n" ) if $Debug;

# call OpenAM and obtain a token
$TokenJson = from_json( `$OAuthTokenUrl` );
print( "JSON returned from OpenAM with access token for Test Spec Bank:\n" ) if $Debug;
print Dumper( $TokenJson )  if $Debug;

# extract the access token
my $TestSpecBankAccessToken = $TokenJson->{ 'access_token' };
print( "TestSpecBankAccessToken = \"$TestSpecBankAccessToken\"\n" ) if $Debug;

#=================================================================================
# determine if the command line paramater is a single file or a directory 
# and process accordingly

# if we have a single file, process it
if( $ProcessingSingleFile )
{
	print( "Path command line parameter is a single file\n" ) if $Debug;
	&ProcessXmlFile( $FilePathParam );
}

# if we have a directory, process all files in the directory
if( $ProcessingDirectory )
{
	print( "Path command line parameter is a directory\n" ) if $Debug;
	my @Dirs;
	push( @Dirs, $FilePathParam );
	find( \&ProcessDirectory, @Dirs );
}

# File::find callback sub to process a file in a directory
sub ProcessDirectory
{
	#store the file find values
	my $XmlPathName = $File::Find::name;
	my $XmlFileDir = $File::Find::dir;
	my $XmlFileName = $_;
	
	print( "Found in directory: \"$File::Find::name\"\n" ) if $Debug;

	# ensure that we are processing a file and not a subdirectory
	if( -f $XmlPathName )
	{
		print( "\"$File::Find::name\" is a file: processing\n" ) if $Debug;
		&ProcessXmlFile( $XmlPathName );
	}
	else
	{
		print( "\"$File::Find::name\" is a not a file: not processing\n" ) if $Debug;
	}
}

#=================================================================================
# process a single XML file

sub ProcessXmlFile
{
	my $FilePath = @_[ 0 ];
	print( "\nProcessing \"$FilePath\"\n" ) if $Debug;
	
	#ensure the file we are processing is an XML file
	if( lc( $FilePath ) =~ /.xml/ )
	{
		print( "\"$FilePath\" is an XML file\n" ) if $Debug;
		print( "Processed XML output:\n" ) if $Debug;
	
		#=========================================================================
		# Some test package variables I will need
		
		my $TestSubjectName;
		my $TestSubjectAbbreviation;
		my $UniqueId;
		my @TestGrades;
		my $TestLabel;
		my $TestType;
		my $TestVersion;

		#=========================================================================
		# read and process the test package file
		
		my @TestPackage;
		open TESTPACKAGEFILE, $FilePath or die ( "Unable to open XML file \"$FilePath\"\n" );
		my $TestTypeFound = $FALSE;
		my $State = 0;
		while( <TESTPACKAGEFILE> )
		{
			if( /<testspecification/ && $State == 0 )	
			{
				/ purpose\s*=\s*\"([^\"]*)\"/;
				my $TestPurpose = $1;
				die( "Not a registration test package\n" ) if( lc( $TestPurpose ) ne "registration" );
				/ publisher\s*=\s*\"([^\"]*)\"/;
				my $TestPublisher = $1;
				/ publishdate\s*=\s*\"([^\"]*)\"/;
				my $TestPublishDate = $1;
				$_ = "<testspecification purpose=\"REGISTRATION\" publisher=\"$TenantId\" publishdate=\"$TestPublishDate\" version=\"1.0\">\n";
				$State = 1;
			}
			
			if( /<identifier/ && $State == 1 )
			{
				/ uniqueid\s*=\s*\"([^\"]*)\"/;
				$UniqueId = $1;
				/ label\s*=\s*\"([^\"]*)\"/;
				$TestLabel = $1;
				#/ version\s*=\s*\"([^\"]*)\"/;
				s/ version\s*=\s*\"([^\"]*)\"/ version=\"$1.0\"/;
				$TestVersion = $1 . ".0";
				$_ = "  <identifier uniqueid=\"$UniqueId\" name=\"$UniqueId\" label=\"$TestLabel\" version=\"$TestVersion\" />";
				$State = 2;
			}
			
			if( /<property\s*name\s*=\s*\"([^\"]*)\"\s*value\s*=\s*\"([^\"]*)\"\s*label\s*=\s*\"([^\"]*)\"/ && $State == 2 )
			{
				my $PropName  = $1;
				my $PropValue = $2;
				my $PropLabel = $3;

				if( lc( $PropName ) eq "subject" )
				{
					my $SubjectFound = $FALSE;
					if( $PropValue eq "ELA" )
					{
						$SubjectFound = $TRUE;
						$TestSubjectName = "English Language Arts";
						$TestSubjectAbbreviation = "ELA";
					}
					if( $PropValue eq "MATH" )
					{
						$SubjectFound = $TRUE;
						$TestSubjectName = "Mathematics";
						$TestSubjectAbbreviation = "MATH";
					}
					if( $PropValue eq "Student Help" )
					{
						$SubjectFound = $TRUE;
						$TestSubjectName = "Student Help";
						$TestSubjectAbbreviation = "SH";
					}
					if( $SubjectFound )
					{
						$_ = "  <property name=\"subject\" value=\"$TestSubjectAbbreviation\" label=\"$TestSubjectName\" />\n";
					}
					else
					{
						die( "Add a subject name for subject abbreviation = \"$PropValue\"\n" )
					}
				}
				
				if( lc( $PropName ) eq "grade" )
				{
					push( @TestGrades, $PropValue );
				}
				
				if( lc( $PropName ) eq "type" )
				{
					if( $PropValue eq "interim" )
					{
						$TestType = "I";
						$TestTypeFound = $TRUE;
					}
					else
					{
						if( $PropValue eq "summative" )
						{
							$TestType = "S";
							$TestTypeFound = $TRUE;
						}
					}
				}
			}
			
			if( /<registration>/ && $State == 2 )
			{
				die( "Test Type not found.\n" ) if !$TestTypeFound;

				$_ = "  <property name=\"label\" value=\"$TestLabel\" label=\"$TestLabel\"/>
  <property name=\"category\"/>
  <property name=\"comment\"/>
  <property name=\"description\"/>
  <property name=\"testfamily\"/>
  <registration>\n";
				$State = 3;
			}
			
			if( /<poolproperty/ && $State == 3 )
			{
				# do nothing: eat the poolproperty; ART doesn't need them
				$_ = "";
			}
			
			if( /<registrationsegment/ && $State == 3 )
			{
				s/fixedform/FIXEDFORM/;
				s/adaptive/ADAPTIVE/;
			}
			
			push( @TestPackage, $_ );
			print if $Debug;
		}
		close( TESTPACKAGEFILE );
		
		#=========================================================================
		# compress and base 64 encode the test package

		my $DeflationStream = deflateInit() or die "Cannot create a deflation stream\n";
		my $Deflated;
		my $Status;
		my $EncodedTestPackage = "";
		open XMLFILE, $FilePath or die ( "Unable to open XML file \"$FilePath\"\n" );
		binmode XMLFILE;
		foreach( @TestPackage )
		{
			( $Deflated, $Status ) = $DeflationStream->deflate( $_ ) ;
			$Status == Z_OK or die( "deflation failed\n" );
			$EncodedTestPackage .= encode_base64( $Deflated );
		}
		( $Deflated, $Status ) = $DeflationStream->flush() ;
		$Status == Z_OK or die( "deflation failed\n" );
		$EncodedTestPackage .= encode_base64( $Deflated );
		$EncodedTestPackage =~ s/[\n\r]//g;
		print( "Compressed and base-64 encoded test package:\n" )if $Debug;
		print( "$EncodedTestPackage\n" ) if $Debug;
		
		#=========================================================================
		# build the test spec bank parameters and convert to JSON
		
		my %Data;
		$Data{ 'specificationXml'    } = $EncodedTestPackage;		
		$Data{ 'tenantId'            } = $TenantId;		
		$Data{ 'category'            } = "";
		$Data{ 'subjectName'         } = $TestSubjectName;		
		$Data{ 'subjectAbbreviation' } = $TestSubjectAbbreviation;	
		$Data{ 'name'                } = $UniqueId;	
		$Data{ 'grade'               } = \@TestGrades;		
		$Data{ 'label'               } = $TestLabel;
		$Data{ 'purpose'             } = "REGISTRATION";	
		$Data{ 'type'                } = $TestType;
		$Data{ 'version'             } = $TestVersion;
		print( "Hash data structure for construction of JSON for call to Test Spec Bank:\n" ) if $Debug;
		print Dumper( \%Data ) if $Debug;
		my $TestJsonBody = to_json( \%Data );
		$TestJsonBody =~ s/\\n/\n/g;
		$TestJsonBody =~ s/\"/\\\"/g;
		$TestJsonBody = "\"" . $TestJsonBody . "\"";
		#my $UriEncodedJsonTestBody = uri_escape( $TestJsonBody );
		my $UriEncodedJsonTestBody = $TestJsonBody;
		print( "JSON Test Body for call to Test Spec Bank:\n" ) if $Debug;
		print( $UriEncodedJsonTestBody ) if $Debug;

		#=========================================================================
		# build the URLs and parameters for Test Spec bank and insert the 
		# registration test package
		
		my $TestSpecBankUrl = "$Configuration{ 'TestSpecBankUri' }/rest/testSpecification";
		my $TestSpecBankParams = "Authorization: Bearer $TestSpecBankAccessToken";
		my $InsertTestUrl = "curl -s --insecure -3 -X POST --data $UriEncodedJsonTestBody $TestSpecBankUrl --header \"$TestSpecBankParams\" --header \"Accept: application/json\" --header \"Content-Type: application/json\"";
		# possibly the line below could work better if the one above has problems (difference being the -s and -3 options)
		# my $InsertTestUrl = "curl --insecure -X POST --data $UriEncodedJsonTestBody $TestSpecBankUrl --header \"$TestSpecBankParams\" --header \"Accept: application/json\" --header \"Content-Type: application/json\"";
		print( "\n" ) if $Debug;
		print( "TestSpecBankUrl = \"$TestSpecBankUrl\"\n" ) if $Debug;
		print( "TestSpecBankParams = \"$TestSpecBankParams\"\n" ) if $Debug;
		print( "InsertTestUrl = \"$InsertTestUrl\"\n" ) if $Debug;

		if( $ExecuteParam )
		{
			print( "Loading Test \"$FilePath\"\n" );
			my $TestSpecBankJson = from_json( `$InsertTestUrl` );
			print( "JSON returned from Test Spec Bank:\n" ) if $Debug;
			print Dumper( $TestSpecBankJson )  if $Debug;
			print( "Inserted registration package \"$FilePath\"\n" );
		}
		else
		{
			print( "--exec not invoked, test not loaded: \"$FilePath\"\n" );
		}
		
		#=========================================================================
	}
	else
	{
		print( "\"$FilePath\" is not an XML file\n" ) if $Debug;
	}
}

#=================================================================================
# transform a test package

sub TransformTestPackage
{
}

#=================================================================================
