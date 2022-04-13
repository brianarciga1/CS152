CS152 Project Phase 1 - Lexical Analyzer Generation Using flex
===============================================================


[Home Page - Phase1 Lexer](https://cs152-ucr-gupta.github.io/website/phase1_lexer.html)


## Tools preparation

Make sure you have a Linux environment for this project. You can use 'bolt', your own Linux machine, or Windows Subsystem for Linux(WSL). We highly recommend you directly use 'bolt' since it contains all the necessary tools preinstalled. 

```sh
ssh <your-net-id>@bolt.cs.ucr.edu
```

Make sure you have the following tools installed and check the version:
1. flex -V       (>=2.5)
2. git --version (>=1.8)
3. make -v       (>=3.8)
4. gcc -v        (>=4.8)
5. g++ -v        (>=4.8 optional if you wish to use C++)

## Clone and Build

Use 'git' to clone the project template and build it by typing 'make'

```sh
    git clone <your-repo-link> phase1
    cd phase1 && make
```

## Use the template

You can change any files and add additional C files, but please make sure all files are linked to the final executable file in Makefile. Please don't change the name of 'Makefile' and 'miniL.lex'. After typing make, An executable file 'miniL' is expected to be created as your phase1 lexer.

## Project Submission 

* Start Date: 4/01/2022
* Due Date:   4/15/2022

Project submission requires you to commit and push your code to Github after finishing the phase1 project. As the following steps:
```sh
git status # it should be under 'main' branch (otherwise you should switch to 'main' branch by typing 'git checkout main')
git add .  # add all files under current folder into staged changes
git commit -m "phase1 submission"  # make a commit for your changes
git push   # push all local commits to Github, this step may need your username and password of Github
```

Before the deadline, you can create commits and push to Github without any limitation. Please make sure your code under 'main' branch is the last version you wish to submit. After the deadline, please do not push new commits to 'main' branch otherwise it will be considered as a late submission.

![image](https://user-images.githubusercontent.com/6300305/148487911-7bcaa3ac-2c8e-4ee3-9ead-ab908d5e1710.png)


## Project Demo and Grading

The project demo will be held in the next lab section after the due date. All teams should attend it since it's important to ensure that your code can move smoothly to the next phase. Contact your TA if you need to change your demo time. 
You grade will be updated on eLearn (usually in 1 week after your demo time). 

| Grading rules | Points(%) |
| ---------------- | -- |
|Successfully Build| 10%|
|Correctness       | 80%|
|Demo              | 10%|

## Academic integrity

Copying source code from students in previous semester and other teams will be considered a violation of academic integrity. 
