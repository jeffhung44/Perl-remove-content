#ARGV[0]    Input file DIR;
#execute    perl [program] [Input DIR] ["Delete_content"] ["Delete_content"] ["Delete_content"] ......



#! /usr/bin/perl

use warnings;
use strict;

my $backup =1;          #Processed files in the new folder /new
my $verbose =1;         #Log on off
my $chk_content =0;
my $log_file="perl.log";
my $log_fh;
my $dir = $ARGV[0];     #Input files DIR
my $out_dir = ".\/new"; #Output files DIR
my $dir_handle;
my $out_dir_handle;
my $file;
my $file_handle;
my $file_out;
my $file_out_handle;
my $fail_cnt = 0;
my $success_cnt = 0;
my $mod_cnt=0;
my $unmod_cnt=0;
my @fail_files;
my @success_files;
my @delete_something = @ARGV;

#//------------------------------
#//Filter the input argument 
##//------------------------------

print "==========The content to be delete==========\n";
for(my $i=1;$i<@delete_something;$i=$i+1){
        print $ARGV[$i]."\n";
}
print "==========The content to be delete==========\n";
#//------------------------------


mkdir($out_dir) unless(-d $out_dir); #create outout files dir;

opendir $dir_handle, $dir or die "can not open dir $dir :$!\n";
opendir $out_dir_handle, $out_dir or die "can not open out_dir $out_dir :$!\n";

foreach $file (readdir $dir_handle){
        # print "there has $file in the file\n";     ######### Check files in the folder;
    
    local $/= undef;
    
    #next if($file =~ /^\./);               #process all folder except . 
    #next if($file =~ /^\.\.$/);            #process all folder except ..
    next if($file =~ /^[.]/);               #skip with .
    next if($file =~ /new/);
    open $file_handle,'<',$file or die " can not open $file : $!\n";
    $file_out = "$file";                #Output file name with suffix .new
    open $file_out_handle, '>', "$out_dir/$file_out" or die " can not open $file_out :$!\n";
    #print $file_out_handle "this is the first line!\n";    #add some text to first line;
    
    my $fullstring = do{local $/;<$file_handle>};       ###### Read Full File into String
    
    open $file_handle,'<',$file or die "can not open $file :$!\n";
    #//------------------------------
    #//Compare the input content and do something
    #//------------------------------
    for(my $i=1;$i<@delete_something;$i=$i+1){
            print "==========CHECK THE CONTENT==========\n";
            print $delete_something[$i]."\n";
        if ($fullstring =~ m/$delete_something[$i]/){
            print "Find same content in: ".$file."\n";
            $fullstring =~ s/$delete_something[$i]//g;
            $mod_cnt++;
        }
        else{
            print "No same content in: ".$file."\n";
            $unmod_cnt++;
        }
    }
    print $file_out_handle $fullstring;

    close $file_out_handle;
    if($unmod_cnt==0){
        $fail_cnt++;
        push(@fail_files,$file);
    }
    else{
        $success_cnt++;
        push(@success_files,$file);
    }

}
    #//------------------------------
    #//Compare the input content and do something
    #//------------------------------

    open $log_fh, '>', "$log_file" or die " can not open $log_file :$!\n";

    #show log
    if ($verbose){
        print"=====================================\n";
        print "List of process files: \n";
        print $log_fh "List of process files: \n";
        print $log_fh "Totaly ".$success_cnt." files\n";
        print join "\n",@success_files;
        print "\n";
        print $log_fh join "\n",@success_files;
        print $log_fh "\n";
        print $log_fh "=====================================\n";
        print"=====================================\n";
        print "list of unprocess files: \n";
        print $log_fh "List of unprocess files: \n";
        print $log_fh "Totaly ".$fail_cnt." files\n";
        print join "\n",@fail_files;
        print "\n";
        print $log_fh join "\n",@fail_files;
        print $log_fh "\n";
        print"=====================================\n";
    }
    print "process $success_cnt files\n";
    print "unrocess $fail_cnt files\n";

    close $log_fh;
    close $dir_handle;
    close $out_dir_handle;


    if (!$backup){
        system("rm $dir/*.v");
        system("cp $dir/new/*.v $dir");
        system("rm -rf $dir/new");
    }
