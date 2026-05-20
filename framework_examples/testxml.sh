rm -f  result.xml
make alone TARGET=test_xml
./test_xml  > result.xml
cat result.xml
