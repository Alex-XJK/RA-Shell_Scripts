# Documentation: DeployStepAutoScript

This is the documentation for DeployStepAutoScript(version: 2), written by Alex J. K. XU on November 25, 2021.  

[TOC]

## Overall

This is an automated shell script that enables the server operations staff to maintain and update the web site continuously. It was originally written by Mr. Jiakai XU from the GAPP team to support the update and release of the GAPP website he was responsible for. Later, with the team's demand for website deploying work, Mr. XU generously decided to standardize the process and package the script for everyone to use.

This program consists one and only one code file `DeployStepAutoScript.sh`.

## Development Team

@author	Jiakai XU			  jiakai.xu@my.cityu.edu.hk		Responsible for the initial writing and maintenance of the entire script.

@author	Xun ZHANG		xunzhang33-c@my.cityu.edu.hk		Provide general guidance and help to Mr. XU on MAC OS and Linux.

## Version Information

- version: 2.+
- since: September, 2021

## Environment

**Macintosh Operating System**

Since Jiakai owns an iMac (Retina 5K, 27-inch, 2017, with macOS Catalina 10.15.7), all of this development work was done on his MAC platform, which may not be supported by other platforms. Among them, the use of Windows (WSL2) platform has been confirmed by colleagues can not be used. We hope that in the future other talented friends can help develop a version that can run successfully in the Windows environment, and we appreciate your kindness.

## Programming Language

- Shell Script

## Parameters

This program takes no input parameters at the beginning, although sometimes you will be required to input a litter bit when our program promotes for them. These things will be explained later in this article.

## Prerequisites

Your site should have been successfully deployed on the server! We are talking about how to redeploy or update an existing website project. How to deploy a web site from scratch is quite complex, and even more complex than the sum of everything covered here, and therefore beyond the scope of this article. Here we are very grateful to Mr. Yi FENG, who worked in the our team last year, for building a relatively comprehensive website initial deployment tutorial, and also to my genius colleague Mr. Xun ZHANG for making some improvements. Their documentation can be found in `"~/zhangxun/deploy_steps/"` on our project's GitLab platform.

## Work-flow

### Connect to cslab VPN

Since our web server `dl380a` is only accessible within cslab intranet, so you must using a cs department wire network (e.g., those PC in cslab) or use your notebook with a cslab VPN connected, the detailed VPN connection guidance can be found [here](https://cslab.cs.cityu.edu.hk/services/cslab-vpn-sonicwall) on cslab official website.

### Git operation

You need to manually update your local repository to the version exactly what you want to deploy, and checkout to the correct branch. Due to the different branch setup of each team, and to avoid other unexpected conflicts, we did not automate this step. We recommend that you use fork or another Git management system to do this.

### Change directory

Needless to say, you need to make sure that the current working directory is your project files (the same ones git uses). If you are already here by now, thank you very much, but you still need to manually type `skip` to let our program know. If you forget to switch that in advance, you also don't need to exit the program, simply enter the corresponding path when our system prompts you (note that, on the MAC you can also drag the corresponding folder in here as usual).

### SSH Key

To ensure that your SSH Key has been successfully activated, we have taken this redundant step to ensure that your SSH key remains active.

```shell
ssh-add
```

### CAP deploy

This is the most important step, but the good news is that you don't have to do anything too complicated to make it. Our program will take care of synchronizing your latest files to the specified location on the server and doing the required pre-compilation and dependency package checking.

The most important instruction is shown below,

```shell
cap production deploy
```

### Web server restart

We do know that on some systems, the previous step already includes an automatic restart process. Unfortunately, on the computer we used for testing, we needed the following extra step to restart the web server.

By executing the following step, the web puma server will restart once,

```shell
bundle exec cap production puma:restart
```

### Ending

At this point, if you are lucky enough to see no error messages, the redeployment of your site should be complete. Thank you very much for using our program.

## Reference

None
