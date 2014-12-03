#!/usr/bin/perl
# EC2 Autoscaling dynamic registration script for HAProxy
# Requirements: SNS topic, SQS subscription
# Notes: Supposed to be run as a cronjob
# John Homer H Alvero
# April 29, 2013
#
# Install pre-reqs by
# yum install perl-Amazon-SQS-Simple perl-Net-Amazon-EC2 --enablerepo=epel
use Amazon::SQS::Simple;
use Net::Amazon::EC2;

my $access_key   = 'CHANGEME';
my $secret_key   = 'CHANGEME';
my $queue_endpoint  = 'https://sqs.us-east-1.amazonaws.com/334542640272/autoscaling_haproxy_queue';
my $haproxy_file  = '/etc/haproxy/haproxy.cfg';
my $my_az  = `wget -qO- http://169.254.169.254/latest/meta-data/placement/availability-zone`;

# Create an SQS object
my $sqs = new Amazon::SQS::Simple($access_key, $secret_key);

# Connect to an existing queue
my $q = $sqs->GetQueue($queue_endpoint);

my $ec2 = Net::Amazon::EC2->new(AWSAccessKeyId => $access_key, SecretAccessKey => $secret_key);

# Retrieve a message
while (1)
{
	while (my $msg = $q->ReceiveMessage())
	{
		$sqs_msg = $msg->MessageBody();

		print "DEBUG: sqs_msg = $sqs_msg\n";
		# If it's a test nofication - delete it and move on
		#if ( $sqs_msg =~ /TEST_NOTIFICATION/)
		#{
		#	print "DEBUG: Deleting TEST_NOTIFICATION\n";
		#	$q->DeleteMessage($msg->ReceiptHandle());
		#	last;
		#}
		# parse message, get instance id
		(my $action = $1, $instance_id = $2) if $sqs_msg =~ /(Terminating|Launching).+EC2InstanceId\\\"\:\\\"(i-.{8})/;

		# do action
		print "DEBUG: action = $action, instance_id = $instance_id\n";
		if ($action eq "")
		{
			print "DEBUG: Deleting non action and moving on\n";
			$q->DeleteMessage($msg->ReceiptHandle());
			last;
		}

		my $running_instances = $ec2->describe_instances(InstanceId => $instance_id);

		foreach my $reservation (@$running_instances)
		{
			foreach my $instance ($reservation->instances_set)
			{
				$pdns_name = $instance->private_dns_name;
				$instance_az = $reservation->instances_set->[0]->placement->availability_zone;
			}
		}

		#if ($my_az eq $instance_az) 
		{
			if ($action eq "Launching")
			{
				print "adding instance id $instance_id $pdns_name\n";

				# Get last app number
				$lastapp = `grep '\# Begin' $haproxy_file -A1000 | grep server | sort -k1 | cut -f6 -d' ' | tail -1`;
				chomp($lastapp);
				$lastapp = "app000" if $lastapp eq "";
				$lastapp++;

				# Update haproxy config file
				system("/bin/echo \"    server $lastapp $pdns_name:8080 check # $instance_id\" >> $haproxy_file | /etc/init.d/haproxy reload");
			}
			elsif ($action eq "Terminating")
			{
				print "removing instance id $instance_id\n";
				system("sed -i \"/$instance_id/d\" $haproxy_file | /etc/init.d/haproxy reload");
			}
			else
			{
				die("unhandled exception. exiting.\n");
			}

			# delete from queue
			$q->DeleteMessage($msg->ReceiptHandle());

		}
		#else
		#{
		#	print "$instance_id $instance_az does not belong to this AZ.\n";
		#}

		# unset variables
		$instance_id = "";
		$launch_id = "";
		$action = "";
		$pdns_name = "";
		$instance_az = "";
	}
	sleep 5;
}
