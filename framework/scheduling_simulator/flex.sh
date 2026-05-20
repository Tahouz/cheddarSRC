aflex scheduler.l
gnatchop -w scheduler.a
gnatchop -w scheduler_io.a
gnatchop -w scheduler_dfa.a
copy scheduler_io.ads.read_from_string scheduler_io.ads
copy scheduler_io.adb.read_from_string scheduler_io.adb
