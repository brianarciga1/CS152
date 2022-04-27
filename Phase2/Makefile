CC = gcc
CFLAGS = -g -O0 -std=c99

miniL: miniL-lex.o miniL-parser.o
	$(CC) $^ -o $@ -lfl

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

miniL-lex.c: miniL.lex miniL-parser.c
	flex -o $@ $< 

miniL-parser.c: miniL.y
	bison -d -v -g -o $@ $<

clean:
	rm -f *.o miniL-lex.c miniL-parser.c miniL-parser.h *.output *.dot miniL
