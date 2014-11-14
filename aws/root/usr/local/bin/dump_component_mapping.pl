#!/usr/bin/perl
use strict;
use LWP::Simple qw(get);
use JSON        qw(from_json);
use Data::Dumper;
#use Try::Tiny;

# Environment-specific defines
my $oauth_access_url;
my $permissions_url;
my $progman_url;

my $env = $ARGV[0]; # or DEV or CI
my $output_file = $ARGV[1];

if ($env eq "UAT")
{
     $oauth_access_url = "https://oam.uat.yourdomain.org/auth/oauth2/access_token?realm=/sbac";
     $permissions_url  = "https://perm.uat.yourdomain.org/rest/mapping";
     $progman_url      = "https://pm.uat.yourdomain.org/rest/propertyConfig/name/Portal/envName/uat";
}
elsif ($env eq "CI")
{
     $oauth_access_url = "https://oam-secure.ci.yourdomain.org/auth/oauth2/access_token?realm=/sbac";
     $permissions_url  = "https://perm.ci.yourdomain.org/rest/mapping";
     $progman_url      = "https://pm.ci.yourdomain.org/rest/propertyConfig/name/Portal/envName/ci";
}
else # catchall for the dev environment
{
     $oauth_access_url = "https://oam-secure.dev.yourdomain.org/auth/oauth2/access_token?realm=/sbac";
     $permissions_url  = "https://perm.dev.yourdomain.org/rest/mapping";
     $progman_url      = "https://pm.dev.yourdomain.org/rest/propertyConfig/name/Portal/envName/dev";
}

my $oauth_params     = "grant_type=password&client_id=pm&client_secret=CHANGEME&username=portal.agent\@example.com&password=CHANGEME";

my $temp;
my $token_url = "curl -s --insecure -3 --data \"$oauth_params\" $oauth_access_url --header \"application/x-www-form-urlencoded\"";

my $mapping_url = "curl -s --insecure -3 $permissions_url";
my $component_url = "curl -s --insecure -3 $progman_url";
my $icon_relative_path = "iconRelativePath";
my $icon_path = "not_found";

my $token_json;
my $mapping_json;
my $component_json;
my $attribute;
my %seen_components;
my $first_role = 1;
my $name;
my $debug = 0;
my @list;
my $sec;
my $min;
my $hour;
my $day;
my $mon;
my $year_1900;
my $wday;
my $yday;
my $isdst;
my $timestamp;
my $role;

print "TOKEN URL IS $token_url\n" if $debug;
$token_json = from_json(`$token_url`);
print Dumper($token_json)  if $debug;

print "JSON: $component_url --header \"Authorization: Bearer $token_json->{'access_token'}\"\n"  if $debug;
$component_json = from_json(`$component_url --header \"Authorization: Bearer $token_json->{'access_token'}\"`);

print "TOKEN: $token_json->{'access_token'}\n"  if $debug;
$mapping_json = from_json(`$mapping_url`);

print "********************************************************************************\n" if $debug;
print Dumper($mapping_json) if $debug;
print "********************************************************************************\n" if $debug;
print Dumper($component_json) if $debug;
print "********************************************************************************\n" if $debug;

# Before we get too far - we need to get the "iconRelativePath"
my @properties  = @{ $component_json->{'properties'} };
foreach $temp (@properties)
{
	if (index($temp->{'propertyKey'}, $icon_relative_path) != -1)
	{
		$icon_path = $temp->{'propertyValue'};
	}
}

my @roles  = @{ $mapping_json->{'value'}{'roles'} };
open (my $fh, ">", $output_file) or die "Could not open $output_file for writing: $!";
foreach $temp (@roles)
{
	print "Roles: " . $temp->{"role"} . "\n" if $debug;
	$role = $temp->{"role"};
	my @components  = @{ $temp->{'mappings'} };
	foreach my $temp_components (@components)
	{
		my $no_spaces_component = $temp_components->{'component'} =~ s/ //gr;
		print "\tComponent: $temp_components->{'component'} $no_spaces_component\n" if $debug;

		$name = $temp_components->{'component'};

		my @propertyValue  = @{ $component_json->{'properties'} };
		my $url;
		my $displayname;
		my $icon;
		foreach $temp (@propertyValue)
		{
			if (index($temp->{'propertyKey'}, $no_spaces_component) != -1)
			{
				$url         = $temp->{'propertyValue'} if ($temp->{'propertyKey'}  =~ /\.url$/);
				$displayname = $temp->{'propertyValue'} if ($temp->{'propertyKey'}  =~ /\.displayname$/);
				$icon        = $temp->{'propertyValue'} if ($temp->{'propertyKey'}  =~ /\.icon$/);
			}
		}
		print $fh "$role|$temp_components->{'component'}|$displayname|$url|$icon_path$icon\n";
	}
}
close $fh;
