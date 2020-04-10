# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    gnl_test.sh                                        :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: lorenuar <lorenuar@student.s19.be>         +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/03/12 11:32:47 by lorenuar          #+#    #+#              #
#    Updated: 2020/04/10 12:19:37 by lorenuar         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

#!/bin/bash
# ********************************* VARIABLES ******************************** #

gnl_main=get_next_line.c
gnl_header=get_next_line.h
gnl_utils=get_next_line_utils.c

# Horrible file name to be sure to not overwrite other's main

random=_random_gen_
result=_result_test_
main_random=_main_random_ignore_me.c
main_stdin=_main_stdin_ignore_me.c
log_file=_diff.log

# ********************************* FUNCTIONS ******************************** #

NO_STDIN=0

if [[ $4 == "-n" ]]; then
	NO_STDIN=1
elif [[ $# != 3 ]]; then
	echo -e "\nUsage : $0 [Length] [Buffer_Max] \
[Tests N Times] [-n No STDIN Test]\n"
	exit 1
fi

success ()
{
	printf "\r\033[32;1mTEST %02d/%2d >OK<\033[0m" $2 $3
}

gen_file_random ()
{
	rm -f $main_random
	echo -e "#include \"get_next_line.h\"" > $main_random
	echo -e "#include <stdio.h>" >> $main_random
	echo -e "#include <fcntl.h>" >> $main_random
	echo -e "" >> $main_random
	echo -e "int		main(int argc, char **argv)" >> $main_random
	echo -e "{" >> $main_random
	echo -e "	char	*line;" >> $main_random
	echo -e "	int		ret = 0;" >> $main_random
	echo -e "	int		fd = 0;" >> $main_random
	echo -e "" >> $main_random
	echo -e "	line = NULL;" >> $main_random
	echo -e "	if (argc == 2)" >> $main_random
	echo -e "		fd = open(argv[1], O_RDONLY);" >> $main_random
	echo -e "	while ((ret = get_next_line(fd, &line)) > 0)" >> $main_random
	echo -e "	{" >> $main_random
	echo -e "		printf(\"%s\\\n\", line);" >> $main_random
	echo -e "		free(line);" >> $main_random
	echo -e "	}" >> $main_random
	echo -e "	printf(\"%s\\\n\", line);" >> $main_random
	echo -e "	free(line);" >> $main_random
	echo -e "	return (0);" >> $main_random
	echo -e "}" >> $main_random
	printf "\033[32;1m$main_random created\033[0m\n"
#	cat -en $main_random
}

test_random ()
{
	for (( i=0 ; i<=$3 ; i++ )); do
		buf=$(( 1 + ($RANDOM * 1000) % $2 ))
		rm -f $random
		head -c $1 /dev/random | env LC_CTYPE=C tr -cd 'A-Za-z0-9\n' >> $random
		echo -e "\n" >> $random
		nchars=$(wc -c $random | tr -d '[A-z] ')
		nlines=$(wc -l $random | tr -d '[A-z] ')
		echo -en  "Test $i/$3\twith file of $nchars char(s)\t and $nlines \
line(s) \tand with BUFFER_SIZE=$buf\t"
		rm -f a.out log
		gcc -Wall -Werror -Wextra -D BUFFER_SIZE=$buf \
$main_random get_next_line.c get_next_line_utils.c
		./a.out $random > $result
		echo -e "" >> $random
		diff -U 50 -q $random $result > $log_file
		if [[ $? == 1 ]]; then
			diff -u $random $result >> $log_file
			printf "\n\n\033[31;1mKO $random !=! $result differs \033[0m\n" >&2
			rm -f $random $result $main_random a.out
			echo -e ">\tcat -nA $log_file\t>"
			cat -nA $log_file
			exit 1
		fi
		rm -f $random $result a.out
#		printf "\033[32;1mSUCCESS\033[0m"
		success " > SUCCESS < " $i $3
		echo
	done
	echo
	rm -f $main_random
}

test_stdin ()
{
	rm -f $main_stdin
	echo -e "#include \"get_next_line.h\"" > $main_stdin
	echo -e "#include <stdio.h>" >> $main_stdin
	echo -e "" >> $main_stdin
	echo -e "int		main(void)" >> $main_stdin
	echo -e "{" >> $main_stdin
	echo -e "	char *line;" >> $main_stdin
	echo -e "	int ret = 0;" >> $main_stdin
	echo -e "	int fd = 0;" >> $main_stdin
	echo -e "" >> $main_stdin
	echo -e "	line = NULL;" >> $main_stdin
	echo -e "	printf(\"\\\n\\033[33;1mTest STDIN Type in C-D when \
you're finished\\033[0m\\\n\");" >> $main_stdin
	echo -e "	while ((ret = get_next_line(fd, &line)) >> 0)" >> $main_stdin
	echo -e "	{" >> $main_stdin
	echo -e "		printf(\"\\t >>> Return %d | '%s' <<<\\\n\", ret, line);" >> $main_stdin
	echo -e "		free(line);" >> $main_stdin
	echo -e "	}" >> $main_stdin
	echo -e "	printf(\"R %d | '%s'\\\n\", ret, line);" >> $main_stdin
	echo -e "	free(line);" >> $main_stdin
	echo -e "	printf(\"\\\\n\\033[32mEND\\033[0m\\\n\");" >> $main_stdin
	echo -e "	return (0);" >> $main_stdin
	echo -e "}" >> $main_stdin
#	cat -en $main_stdin

	rm -f a.out
	gcc -Wall -Werror -Wextra -D BUFFER_SIZE=1 \
$main_stdin get_next_line.c get_next_line_utils.c
	./a.out
	rm -f $main_stdin a.out
}
# **************************************************************************** #

if [[ ! -f $gnl_main ]]; then
	printf "\033[31;1mERROR $gnl_main not found\033[0m" >&2
	exit 2
fi
if [[ ! -f $gnl_header ]]; then
	printf "\033[31;1mERROR $gnl_header not found\033[0m" >&2
	exit 2
fi
if [[ ! -f $gnl_utils ]]; then
	sprintf "\033[31;1mERROR $gnl_utils not found\033[0m" >&2
	exit 2
fi
gen_file_random

test_random $1 $2 $3

if [[ $NO_STDIN == 0 ]]; then
	test_stdin
fi
