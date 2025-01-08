CC = gcc
CFLAGS = -Wall -Wextra -Werror -I../ # Added -I../ to specify the directory for header files

#source files
MANDATORY_SRC = ../get_next_line.c ../get_next_line_utils.c
BONUS_SRC = ../get_next_line_bonus.c ../get_next_line_utils_bonus.c
HEADER = ../get_next_line.h
BONUS_HEADER = ../get_next_line_bonus.h
TESTER_SRC = mainWIZ.c

#object files
OBJ = $(MANDATORY_SRC:.c=.o) $(TESTER_SRC:.c=.o)
BONUS_OBJ = $(BONUS_SRC:.c=.o) $(TESTER_SRC:.c=.o)

NAME = gnl_tester
BONUS_NAME = gnl_tester_bonus

all: $(NAME)

$(NAME): $(OBJ)
	$(CC) $(CFLAGS) -o $(NAME) $(OBJ)

bonus: $(BONUS_OBJ)
	$(CC) $(CFLAGS) -o $(BONUS_NAME) $(BONUS_OBJ)

../get_next_line.c:
	@echo "Error: Could not find ../get_next_line.c. Make sure the tester is in the correct folder!!!" && exit 1

../get_next_line_bonus.c:
	@echo "oh No bonus files found. :< Skipping bonus target then."

clean:
	rm -f $(OBJ) $(BONUS_OBJ)

fclean: clean
	rm -f $(NAME) $(BONUS_NAME)

re: fclean all

cast_test:
	bash Cast_tester.sh

.PHONY: all bonus clean fclean re test