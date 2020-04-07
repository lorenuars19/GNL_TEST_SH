# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    gen_random_chars.sh                                :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: lorenuar <lorenuar@student.s19.be>         +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/03/12 11:32:47 by lorenuar          #+#    #+#              #
#    Updated: 2020/03/12 14:33:24 by lorenuar         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

#!/bin/zsh
# ********************************* VARIABLES ******************************** #

name=random

# ********************************* FUNCTIONS ******************************** #

NO_STDIN=0
if [[ $4 == "-n" ]]; then
	NO_STDIN=1
elif [[ $# != 3 ]]; then
	echo "\nUsage : $0 [Length] [Buffer_Max]\
[Tests N Times] [-n No STDIN Test]\n"
	exit 1
fi

gen_file_random ()
{
	rm -f main_random.c
	echo "#include \"get_next_line.h\"" > main_random.c
	echo "#include <stdio.h>" >> main_random.c
	echo "#include <fcntl.h>" >> main_random.c
	echo "" >> main_random.c
	echo "int		main(int argc, char **argv)" >> main_random.c
	echo "{" >> main_random.c
	echo "	char	*line;" >> main_random.c
	echo "	int		ret = 0;" >> main_random.c
	echo "	int		fd = 0;" >> main_random.c
	echo "" >> main_random.c
	echo "	line = NULL;" >> main_random.c
	echo "	if (argc == 2)" >> main_random.c
	echo "		fd = open(argv[1], O_RDONLY);" >> main_random.c
	echo "	while ((ret = get_next_line(fd, &line)) > 0)" >> main_random.c
	echo "	{" >> main_random.c
	echo "		printf(\"%s\\\n\", line);" >> main_random.c
	echo "		free(line);" >> main_random.c
	echo "	}" >> main_random.c
	echo "	printf(\"%s\\\n\", line);" >> main_random.c
	echo "	free(line);" >> main_random.c
	echo "	return (0);" >> main_random.c
	echo "}" >> main_random.c
	echo "\033[32;1mmain_random.c created\033[0m"
}

test_random ()
{
	for (( i=0 ; i<$3 ; i++ ))
	do
		buf=$(( 1 + ($RANDOM * 1000) % $2 ))
		rm -f $name
		head -c $1 /dev/random | env LC_CTYPE=C tr -cd 'A-Za-z0-9\n' >> $name
		echo "" >> $name
		nchars=$(wc -c $name | tr -d '[A-z] ')
		nlines=$(wc -l $name | tr -d '[A-z] ')
		printf  "\nTest with file of $nchars char(s) and $nlines \
line(s) and with BUFFER_SIZE=$buf\t"
		rm -f a.out log
		gcc -Wall -Werror -Wextra -D BUFFER_SIZE=$buf \
main_random.c get_next_line.c get_next_line_utils.c
		./a.out random > result
		echo "" >> $name
		diff -U 50 -q random result
		if [[ $? == 1 ]]; then
			echo ""
			diff -U 3 random result | cat -e > log
			echo "\033[31;1mERROR FILE $name & result DIFFERS \
(look at log file for more information)\033[0m" >&2
			rm -f random result main_random.c a.out
			exit 1
		fi
		rm -f random result  a.out
		printf "\033[32;1mSUCCESS\033[0m"
	done
	echo
	rm -f main_random.c
}

test_stdin ()
{
	rm -f main_stdin.c
	echo "#include \"get_next_line.h\"" > main_stdin.c
	echo "#include <stdio.h>" >> main_stdin.c
	echo "" >> main_stdin.c
	echo "int		main(void)" >> main_stdin.c
	echo "{" >> main_stdin.c
	echo "	char *line;" >> main_stdin.c
	echo "	int ret = 0;" >> main_stdin.c
	echo "	int fd = 0;" >> main_stdin.c
	echo "" >> main_stdin.c
	echo "	line = NULL;" >> main_stdin.c
	echo "	printf(\"\\\n\\033[33;1mTest STDIN Type in C-D when \
you're finished\\033[0m\\\n\");" >> main_stdin.c
	echo "	while ((ret = get_next_line(fd, &line)) >> 0)" >> main_stdin.c
	echo "	{" >> main_stdin.c
	echo "		printf(\"R %d | '%s'\\\n\", ret, line);" >> main_stdin.c
	echo "		free(line);" >> main_stdin.c
	echo "	}" >> main_stdin.c
	echo "	printf(\"R %d | '%s'\\\n\", ret, line);" >> main_stdin.c
	echo "	free(line);" >> main_stdin.c
	echo "	printf(\"\\\n\\033[32mEND\\033[0m\\\n\");" >> main_stdin.c
	echo "	return (0);" >> main_stdin.c
	echo "}" >> main_stdin.c

	rm -f a.out
	gcc -Wall -Werror -Wextra -D BUFFER_SIZE=1 \
main_stdin.c get_next_line.c get_next_line_utils.c
	./a.out
	rm -f main_stdin.c a.out
}
# **************************************************************************** #

gen_file_random
test_random $1 $2 $3
if [[ $NO_STDIN == 0 ]]; then
	test_stdin
fi
