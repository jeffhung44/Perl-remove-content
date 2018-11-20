#ARGV[0] Input file DIR;
#ARGV[1] Output file DIR;
#execute perl [program] [Input DIR] ["Delete_content"] 
#for example perl delete_content.pl ./ ./rst "task satam\;.*endtask"

use warnings;
use strict;

my $verbose =1;
my $dir = $ARGV[0];     #Input files DIR
my $out_dir = ".\/rst"; #Output files DIR
my $dir_handle;
my $out_dir_handle;
my $file;
my $file_handle;
my $file_out;
my $file_out_handle;
my $fail_cnt = 0;
my $success_cnt = 0;
my @fail_files;
my @success_files;
my $delete_something = qr/$ARGV[1]/s;


mkdir($out_dir) unless(-d $out_dir); #create outout files dir;

opendir $dir_handle, $dir or die "can not open dir $dir :$!\n";
opendir $out_dir_handle, $out_dir or die "can not open out_dir $out_dir :$!\n";

foreach $file (readdir $dir_handle){
        # print "there has $file in the file\n";     ######### Check files in the folder;
    
    local $/= undef;
    
    #next if($file =~ /^\./);               #process all folder except . 
    #next if($file =~ /^\.\.$/);            #process all folder except ..
    next if($file =~ /^[.]/);               #skip with .
    open $file_handle,'<',$file or die " can not open $file : $!\n";
    $file_out = "$file";                #Output file name with suffix .new
    open $file_out_handle, '>>', "$out_dir/$file_out" or die " can not open $file_out :$!\n";
    #print $file_out_handle "this is the first line!\n";    #add some text to first line;
    
    my $fullstring = do{local $/;<$file_handle>};       ###### Read Full File into String
    
    open $file_handle,'<',$file or die "can not open $file :$!\n";
    if ($fullstring =~ m/$delete_something/){
            # print "Found same content in: ".$file."\n";
            $success_cnt++;
            push(@success_files,$file);
            $fullstring =~ s/$delete_something//g;
            print $file_out_handle $fullstring;
    }
    else{
            # print "there has no same content in: ".$file."\n";
            $fail_cnt++;
            push(@fail_files,$file);
            while(<$file_handle>){
                #print $file_out_handle "it prints something\n";
                print $file_out_handle $_;
            }
    }

    close $file_out_handle;
}


    #show log
    if ($verbose){
    print "list of succesful files: \n";
    print "@success_files","\n";
    print "list of unprocess files: \n";
    print "@fail_files","\n";
    }
    print "process $success_cnt files\n";
    print "unrocess $fail_cnt files\n";


    close $dir_handle;
    close $out_dir_handle;

    system("rm *.v");
    system("cp ./rst/*.v ./");
    system("rm -rf ./rst");
