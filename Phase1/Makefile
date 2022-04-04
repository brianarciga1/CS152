CC = gcc
CFLAGS = -g -O0 -std=c99

miniL: miniL-lex.o
	$(CC) $< -o $@ -lfl

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

miniL-lex.c: miniL.lex
	flex -o $@ $< 

clean:
	rm -f *.o miniL-lex.c miniL