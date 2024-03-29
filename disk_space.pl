#!/perl/v5.20.1/bin/perl
use strict;
use Filesys::Df;
use Text::Table;
use MIME::Lite;
use Term::ANSIColor;
my @disk_space;
my @disk_space_threshold;
my %disk_space;
my $dump_file="/tmp/$$.txt";
open (FH , ">> $dump_file");
my %site=(
        "A" => "/net/abc/vol/sfi_vol1/grid",
        "B" => "/net/def-s1/vols/grid",
        "C    => "/net/ghi/vol/sfi/grid",
        "D => "/net/jkl/vol/sfi_vol02/SFICommonTools/grid",
        "E"   => "/net/mno/vol0/grid",
        "F"     => "/net/pqr/vol/vol2/sfi_tools",
        "G" => "/net/stu-s1//grid/sfi/grid",
        "H"      => "/net/vwx-p2/it/SFI_grid2/common_tools/grid",
);
         
for my $item (keys %site) 
{
	my $disk_info = df("$site{$item}");
	my $threshold = 58;
	my $disk_percent;

	if (defined($disk_info))
	{ 
      		my $disk_percent = $disk_info->{per};
		#push(@disk_space,"\n$item => $disk_percent%");
		$disk_space{$item}=$disk_percent;

		if ($disk_percent > $threshold)
		{
			my $space=`df -h $site{$item}`;
			push (@disk_space_threshold,"\n$item => $disk_percent%\n");
			push (@disk_space_threshold,"\n$space\n\n");
			
		#	`echo "$space\n" |mail -s "Disk space for common area on  site $item is $disk_percent% full. Need to add more disk space" "niraj\@abc.com
		}
	}
}

my  $table = Text::Table->new("Site","Used Disk Space%");
foreach my $key(keys %disk_space){
$table->add(
                       $key,
                       "$disk_space{$key}",
                       );    # a record of data
        }
#$table_51->add(' ');   #ADD AN EMPTY Record

if(@disk_space_threshold)
{
	print FH "Disk space on the following sites have been crossed threshold limit:\n";
	print FH "@disk_space_threshold\n\n";
	print FH "================================\n\n";
	print FH "Consumed disk space for rest of the sites:\n\n";
	print FH "$table\n";
#	`cat $dump_file |mail -s "Disk space for common area on few of sites nearing 100% full" "niraj\@abc.com
	&mail();
}

#`rm -f $dump_file`;

sub mail{
my $to = 'niraj@abc.com
my $from = 'niraj';
my $subject = 'Disk space for common area on few of sites nearing 100% full';

my $log_file = "$dump_file"; # are you sure it's /message 
                               # and not ./message?
#my $file_content;

#{                         
#  local $/ = undef;
  open FILE, '<', $log_file or die "open $log_file: $!\n";
 my $file_content = <FILE>;
#  close FILE or warn "close $log_file: $!\n";
#  }
  
open MAIL, "|/usr/sbin/sendmail -t";

## Mail Header
print MAIL "To: $to\n";
print MAIL "From: $from\n";
print MAIL "Subject: $subject\n\n";
## Mail Body
print MAIL $file_content;

close MAIL;
}
