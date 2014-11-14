#!/usr/bin/perl
use strict;

use Net::Amazon::EC2;
use Data::Dumper;
use Date::Calc;
#use Time::localtime;

my $all_instances;
my $all_snapshots;
my $reservation;
my $instance;
my $tag;
my %hashed_tag;
my @array_tag;
my %instance_state;
my $block_device;
my $tag_names;
my $pretty_name;
my $i;
#my $tm=localtime;
#my ($day,$month,$year)=($tm->mday,$tm->mon,$tm->year);
my ($year,$month,$day) = Date::Calc::Today();
my $description;
my $snapshot;
my ($keyword,$server,$date);
my ($snap_month, $snap_day, $snap_year);
my $delta_days;
my @split_array;

my $OWNER_ID = "334542640272";
my $BACKUP_KEYWORD = "Backup";
my $DAYS_TO_KEEP = 3;

my $ec2 = Net::Amazon::EC2->new
(
   AWSAccessKeyId => 'AKIAIHNGVDVV56YKVP5Q', 
   SecretAccessKey => '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',
   return_errors => 1
);


$all_instances = $ec2->describe_instances;
#@print Dumper($all_instances);

foreach $reservation (@$all_instances)
{
	foreach $instance ($reservation->instances_set)
	{
		next if($instance->instance_state->name ne "running");

		foreach $tag_names ($instance->tag_set)
		{
			next if ! defined($tag_names);
			foreach $i(@$tag_names)
			{
				$pretty_name = $i->value if ($i->key eq "Name");
			}
		}

		foreach $block_device ($instance->block_device_mapping)
		{
			next if ! defined($block_device);
			foreach $i(@$block_device)
			{
				$description = "$BACKUP_KEYWORD $pretty_name:" . $i->device_name . " $month/$day/$year";
				print "ec2->create_snapshot(VolumeId => " . $i->ebs->volume_id . ", Description => \"$description\");\n";
				$ec2->create_snapshot(VolumeId => $i->ebs->volume_id , Description => $description);
			}
		}
	}
}

#Now let's clear out the old backups
$all_snapshots = $ec2->describe_snapshots(Owner => $OWNER_ID);
#print Dumper($all_snapshots);
print "Looking to remove $BACKUP_KEYWORD snapshots older than $DAYS_TO_KEEP days\n";
foreach $snapshot (@$all_snapshots)
{
	if ($snapshot->description =~ /^$BACKUP_KEYWORD/)
	{
		print $snapshot->description . "\n";
		$date = (split(' ',$snapshot->description))[-1];
		($snap_month, $snap_day, $snap_year) = $date =~ /(\d+)\/(\d+)\/(\d+)/;
		$delta_days = Date::Calc::Delta_Days($snap_year, $snap_month,$snap_day, $year,$month,$day);
		if ($delta_days > $DAYS_TO_KEEP)
		{
			print "Removing " . $snapshot->description . "... ";
			if ($ec2->delete_snapshot(SnapshotId => $snapshot->snapshot_id))
			{
				print "Successful\n"
			}
			else
			{
				print "Failed\n"
			}
		}
	}
}
