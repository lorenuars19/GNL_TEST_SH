# GNL_TEST_SH
Tester for get_next_line 42 project
## Tests
tests your get_next_line with random strings and with stdin 
# Usage
- Copy the script to your working directory 
- `curl https://raw.githubusercontent.com/lorenuars19/GNL_TEST_SH/master/gnl_test.sh -o gnl_test.sh `
- launch the script with `bash gnl_test.sh [Length] [Buffer_Max] [Tests N Times] [-n No STDIN Test]`
## Notes
Scripts returns non-zero status code if the test fails so you can chain it with other tests
