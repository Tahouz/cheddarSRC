
# After Ada code generation, dont forget:

# 1) to copy
# cp scheduler_io.adb.read_from_string scheduler_io.adb
# cp scheduler_io.ads.read_from_string scheduler_io.ads
#
# 2) to update scheduler_lex.adb by changing the following yyrestart 
# subprogram to handle a unbounded_string_parameter
#
# with ada.strings.unbounded;
# use  ada.strings.unbounded;
#
#procedure yyrestart( input_file : file_type ) is
#begin
#   open_input(to_unbounded_string(text_io.name(input_file)));
#end yyrestart;
#

all:: scheduler_lex.adb parser.adb 


flex : 
	aflex scheduler.l
yacc : 
	ayacc scheduler.y

scheduler_lex.adb: scheduler.l
	aflex scheduler.l 
	gnatchop -w scheduler_io.a 
	gnatchop -w scheduler.a 
	gnatchop -w scheduler_dfa.a 

parser.adb: scheduler.y
	ayacc scheduler.y
	gnatchop -w scheduler.a 
	touch parser.adb

clean::
	$(RM) *.a 



