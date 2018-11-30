#ARGV[0]    Input file DIR;
#execute    perl [program] [Input DIR] ["Delete_content"] 
#for example perl delete_content.pl ./ "task int_satam\;.*endtask"
#it will delete the content like that :
#
#task int_satam;
#begin
#  //$display($time, " JR0325A INT : Enter SATA Model Interrupt Service Routine");
#    fork
#        if(sim.satam0.int_rxfis_h2dreg)
#        begin
#            sim.satam0.int_rxfis_h2dreg = 0;
#            sim.satam0.get_rxmem_h2dreg;
#            sim.satam0.cmd_dispatch;
#        end
#        .
#        .
#        .
#        if(sim.satam5.int_rxfis_data)
#        begin
#            sim.satam5.int_rxfis_data = 0;
#            -> sim.satam5.event_rxfis_data;
#        end
#    join
#end
#endtask



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
    next if($file =~ /new/);
    next if($file =~ /.sh$/);
    next if($file =~ /.log$/);
    open $file_handle,'<',$file or die " can not open $file : $!\n";
    $file_out = "$file";                #Output file name with suffix .new
    open $file_out_handle, '>', "$out_dir/$file_out" or die " can not open $file_out :$!\n";
    #print $file_out_handle "this is the first line!\n";    #add some text to first line;
    
    my $fullstring = do{local $/;<$file_handle>};       ###### Read Full File into String
    
    open $file_handle,'<',$file or die "can not open $file :$!\n";
    if ($fullstring =~ m/$delete_something/){
            print "Find same content in: ".$file."\n";
            print "===============The matched content is :===============\n";
            print "Found: \n$&\n";                        ##### Print matched Content #####
            print "===============^^^^^^^^^^^^^^^^^^^^^^^^===============\n";
            $success_cnt++;
            push(@success_files,$file);
            $fullstring =~ s/$delete_something//g;
            print $file_out_handle $fullstring;
    }
    else{
            print "No same content in: ".$file."\n";
            $fail_cnt++;
            push(@fail_files,$file);
            while(<$file_handle>){
                #print $file_out_handle "it prints something\n";
                print $file_out_handle $_;
            }
    }

    close $file_out_handle;
}

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