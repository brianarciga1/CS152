CS152 Lab: A Calculator Example
===================================

[home page for lab1](https://www.cs.ucr.edu/~dtan004/proj1/lab01_lexer.html)

[home page for lab2](https://www.cs.ucr.edu/~dtan004/proj2/lab02_parser.html)


## Tools preparation

Make sure you have a Linux environment for this project. You can use 'bolt', your own Linux machine, or Windows Subsystem for Linux(WSL). I highly recommend you directly use 'bolt' since it contains all the necessary tools preinstalled. 

```sh
ssh <your-net-id>@bolt.cs.ucr.edu
```

Make sure you have the following tools installed and check the version:
1. flex -V       (>=2.5)
2. git --version (>=1.8)
3. make -v       (>=3.8)
4. gcc -v        (>=4.8)
5. g++ -v        (>=4.8 optional if you wish to use C++)

## Clone 

Use 'git' to clone the project template:

```sh
    git clone <your-repo-link> lab1
```

## Check Your Tasks for Lab 1

Read the documentation of flex and your tasks in [home page for lab1](https://www.cs.ucr.edu/~dtan004/proj1/lab01_lexer.html). From this starter template, you can edit 'calc.lex' to finish tasks step by step.  

## Using Flex to generate C source code

Here is a basic FLEX tutorial: http://alumni.cs.ucr.edu/~lgao/teaching/flex.html

flex can generate C source code of a lexer using flex specification 'calc.lex' in our lab.

```sh
flex -o calc.c calc.lex
```

After generate the C code, we can use gcc to compile it and link flex library 'fl' to support its functionailty.

```sh
gcc calc.c -lfl -o calc
```

The lexer will read from STDIN and tokenize your input stream by running actions defined in your specification.

We recommand you to write a Makefile to avoid typing these commands repeatly.



## Keep your progress by uploading to Github

After you finish all 4 tasks, you are done the first part of this lab. You don't need to submit the code but should keep your progress until next time when we start learning syntax analysis. 

Uploading to Github is a safe way:

```sh
git add .  # add all files under current folder to staged changes
git commit -m "lab1 - lexer"  # create a new commit
git push   # upload to Github, it may requires your username and password of Github
```

