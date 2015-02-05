#!/usr/bin/perl
use strict;
use warnings;
#use Data::Dump qw/ddx/;
my $FIREWALL_RULES = "./firewalls.txt";
my $EC2_FIREWALL_PRINT = "aws ec2 describe-security-groups --group-names ";
my $DOMAIN = "opentestsystem.org";
my $EXTERNAL = "ext";
my $DEBUG = 0;

my $prefix = 0;
my $protocol = 0;
my @prefixes;
my @row_elements;
my %protocol_number;
my %protocol_name;
my %ports_open;
my %security_group;

my ($env_option, $env) = @ARGV;

sub read_firewall_rules()
{
	my $fh;
	my $row;
	my $row_num = 0;
	if (open($fh, '<:encoding(UTF-8)', $FIREWALL_RULES))
	{
		while ($row = <$fh>)
		{
			$row_num++;

			next if ($row =~ /^ext/);
			next if ($row =~ /^,/);
			chomp $row;
			#print "$row\n";

			if ($row =~ /^Prefix/)
			{
				$prefix = 1;
				@prefixes = split /,/, $row;
				for (@prefixes)
				{
					s/$/.$env.$DOMAIN/;
				}
				next;
			}
			if ($row =~ /^Protocol/)
			{
				$protocol = 1;
				$prefix = 0;
				next;
			}

			@row_elements = split /,/, $row;

			if ($prefix)
			{
				$row_elements[0] =~ s/$/.$env.$DOMAIN/;
				print "Checking firewall for $row_elements[0]\n" if ($DEBUG);
				for my $i (2 .. $#row_elements)
				{
					if ($row_elements[$i] ne '')
					{
						my @ports = split /\//, $row_elements[$i];
						foreach (@ports)
						{
							#print "port open: $_\n";
							$ports_open{$row_elements[0]}{$prefixes[$i]}{$_}++;
						}
					}
				}
			}
			if ($protocol)
			{
				$protocol_number{$row_elements[1]} = $row_elements[0];
				$protocol_name{$row_elements[0]} = $row_elements[1];
			}
		}
	}
	else
	{
		print "Unable to open $FIREWALL_RULES: $!";
		exit;
	}
}

sub usage()
{
	print "-e env_to_check\n";
	exit;
}


sub print_firewall_rules()
{
	my $server;
	my $incoming_server;
	my $port_name;

	foreach $server (sort keys %ports_open)
	{
		print "server - $server\n";
		foreach $incoming_server (sort keys %{ $ports_open{$server} })
		{
			print "\tincoming server - $incoming_server\n";
			foreach $port_name (sort keys %{ $ports_open{$server}{$incoming_server} })
			{
				print "\t\tport name: $port_name\n";
			}
		}
		print "\n";
	}
}

sub print_security_groups()
{
	my $server;
	my $incoming_server;
	my $port_name;

	foreach $server (sort keys %security_group)
	{
		print "server - $server\n";
		foreach $incoming_server (sort keys %{ $security_group{$server} })
		{
			print "\tincoming server - $incoming_server\n";
			foreach $port_name (sort keys %{ $security_group{$server}{$incoming_server} })
			{
				print "\t\tport name: $port_name\n";
			}
		}
		print "\n";
	}
}

sub print_port_numbers()
{
	my $port;

	foreach $port (keys %protocol_number)
	{
    		print "$port = $protocol_number{$port}\n";
	}
}

sub read_security_groups()
{
	my $server;
	my $incoming_server;
	my $port_name;
	my $current_server;
	my $current_port;
	my $current_remote_server;
	my $current_ip_range;

	foreach $server (sort keys %ports_open)
	{
		my $line;
		my $output = qx($EC2_FIREWALL_PRINT $server);
		my @elements;

		foreach $line (split /\n/, $output)
		{
			@elements = split /\s+/, $line;
			#print "$line ([0] is $elements[0])\n";
			if ($elements[0] =~ /SECURITYGROUPS/)
			{
				$current_server = $elements[1];
			}
			if ($elements[0] =~ /IPPERMISSIONS/)
			{
				$current_port = $elements[1];
				if (! exists($protocol_number{$current_port}))
				{
					print "Port $current_port on $current_server is not defined in the $FIREWALL_RULES file\n";
					print "$line\n";
					#$protocol_number{$current_port} = $current_port;
				}
			}
			if ($elements[0] =~ /USERIDGROUPPAIRS/)
			{
				$current_remote_server = $elements[2];

				$security_group{$current_server}{$current_remote_server}{$current_port}++;
			}
			if ($elements[0] =~ /IPRANGES/)
			{
				$current_ip_range = $elements[1];
			        if ($current_ip_range =~ /^0.0.0.0/)
				{
					$current_ip_range = "$EXTERNAL.$env.$DOMAIN";
				}

				$security_group{$current_server}{$current_remote_server}{$current_port}++;
			}
		} 
	}
}

sub compare_firewall_and_security_groups()
{
	my $server;
	my $incoming_server;
	my $port;

	print "\n$FIREWALL_RULES file entries that aren't in the Security Groups\n";
	foreach $server (sort keys %ports_open)
	{
		foreach $incoming_server (sort keys %{ $ports_open{$server} })
		{
			foreach $port (sort keys %{ $ports_open{$server}{$incoming_server} })
			{
				if (exists($security_group{$server}{$incoming_server}{$protocol_name{$port}}))
				{
					delete($security_group{$server}{$incoming_server}{$protocol_name{$port}});
				}
				else
				{
					$incoming_server = "EXTERNAL" if ($incoming_server =~ /^ext\./);
					print "Port $port is not in the Security Group \"$server\" to allow $incoming_server in\n";
				}
			}
		}
	}
	print "\nSecurity Group Entries that don't match $FIREWALL_RULES file\n";
	foreach $server (sort keys %security_group)
	{
		foreach $incoming_server (sort keys %{ $security_group{$server} })
		{
			foreach $port (sort keys %{ $security_group{$server}{$incoming_server} })
			{
				print "Port $port is defined in Security Group \"$server\" to allow $incoming_server\n";
			}
		}
	}
}

if (not defined $env_option) 
{
	usage();
}

if (not defined $env) 
{
	usage();
}

if (not defined $ENV{"AWS_ACCESS_KEY_ID"})
{
	print "Please \'. /usr/local/etc/ec2.env\' before running this program\n";
	exit;
}

read_firewall_rules();
print_firewall_rules() if ($DEBUG);
print_port_numbers() if ($DEBUG);
read_security_groups();
print_security_groups() if ($DEBUG);
compare_firewall_and_security_groups();
