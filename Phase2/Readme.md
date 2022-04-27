CS152 Project Phase 2 - Parser Generation Using bison
===============================================================


[Home Page - Phase2 Parser](https://cs152-ucr-gupta.github.io/website/phase2_parser.html)


## Tools preparation

Make sure you have a Linux environment for this project. You can use 'bolt', your own Linux machine, or Windows Subsystem for Linux(WSL). We highly recommend you directly use 'bolt' since it contains all the necessary tools preinstalled. 

```sh
ssh <your-net-id>@bolt.cs.ucr.edu
```

Make sure you have the following tools installed and check the version:
1. flex -V       (>=2.5)
2. bison -V      (>=3.0)
3. git --version (>=1.8)
4. make -v       (>=3.8)
5. gcc -v        (>=4.8)
6. g++ -v        (>=4.8 optional if you wish to use C++)

## Clone and Build

First, please create your own repository by click 'Use this template' button and make sure you create a private repository (one repository per team) in your Github account.
![image](https://user-images.githubusercontent.com/6300305/150668401-cfa3cd5f-1762-4b51-aec5-d1b6e097a559.png)
Then, please add your team member and your TA for rights of accessing your repository by selecting 'Settings' -> 'Manage access' -> 'Add people':
![image](https://user-images.githubusercontent.com/6300305/150668476-ebc35b05-7c94-4e23-a816-09deda6f5278.png)
Your TA's Github account:
* Xiaolin Jiang -  xlinlin23
* Mahbod Afarin   -  mahbod-art

Finally, use 'git' to clone the project into your own machine or bolt, and copy your code in phase 1 into this new repository.

```sh
    git clone <your-repo-link> phase2
    cd phase2 && make
```

## Use the template

You can change any files and add additional C/C++ files, but please make sure all files are linked to the final executable file in Makefile. Please don't change the name of 'Makefile' , 'miniL.lex' and 'miniL.y'. After typing make, An executable file 'miniL' is expected to be created as your phase2 parser.

## Project Submission 

* Start Date: 4/15/2022
* Due Date:   5/13/2022

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
