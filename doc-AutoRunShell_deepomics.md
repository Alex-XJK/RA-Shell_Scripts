# Documentation: AutoRunShell

This is the documentation for AutoRunShell (version: -"deepomics"  -te), written by Alex J. K. XU on November 23, 2021.  

[TOC]



## Overall

This `AutoRunShell` shell script was written by Mr. Jiakai XU from the GAPP development team to automate the entire bio-analysis process together with the final report generation function. It was initially debugged on the delta2 server, but after time and several analysis proved its accuracy and usability, we adapted it to the deepomics.org website for official use.  

This whole program consists of three files, main shell `AutoRunShell-*.sh`,  `generate_script.sh` for generate all the bio-analysis related scripts, and `generate_json.sh` for the report generation need.

## Development Team

@author	Jiakai XU			  jiakai.xu@my.cityu.edu.hk		Responsible for the overall design, coding and debugging of the whole shell. Participate in debugging of biological analysis module and adaptation of new generation exps program.

@author	Shiying LI			shiyingli7-c@my.cityu.edu.hk	Provide the initial `generate_script` code and provide some technical advice.	

@author	Xun ZHANG		xunzhang33-c@my.cityu.edu.hk		Responsible for assisting debugging the whole program, mainly responsible for finding and confirming the correct path of all required files and resources, as well as the design of related folder structure. Participate in the adaptation of new generation exps program.

@author 	Yuqin HUANG	yqhuang23-c@my.cityu.edu.hk	Responsible for the adaptation and debugging of the new infres program. 

## Version Information

- -deepomics : Online deepomics platform used only. We considered the relative resource location and file access permission inside the deepomics docker.
- -t : Running time will be compute and displayed in a human readable way.
- -e : We redirected the stderr stream to the same as stdout stream to make running log more easy to read on the deepomics website.
- version : deepomics 3.+
- since : November 19, 2021

## Parameters

1. -v    <u>v</u>cf location
   - [critical] [default]
   - This variable points to the final vcf file location after bio-analysis process, e.g., `"./test/data.anno.hg38_multianno.vcf"` this may depends on the different analysis process and is set by the developer in advanced.
2. -i    user <u>i</u>d 
   - [critical] [required]
   - This variable is used to locate the original gene file on the server disk, for example, if your user_id is "XYZ" and the file name is "ABC", then the files we are looking for should located at `"/disk2/workspace/platform/gapp/userXYZ/data/ABC_1.fq.gz"` and `"/disk2/workspace/platform/gapp/userXYZ/data/ABC_2.fq.gz"`
   - Sample input: `56190000`
3. -f    <u>f</u>ile name
   - [critical] [required]
   - This variable is used to locate the original gene file on the server disk, for example, if your user_id is "XYZ" and the file name is "ABC", then the files we are looking for should located at `"/disk2/workspace/platform/gapp/userXYZ/data/ABC_1.fq.gz"` and `"/disk2/workspace/platform/gapp/userXYZ/data/ABC_2.fq.gz"`
   - Sample input: `GENE`
4. -k    report <u>k</u>ey  
   - [critical] [optional]
   - The unique tag for your final PDF and HTML report.
   - If not given, our system will give your one sequence of digits according to the current system time stamp. (Do not hope to brute force guess other's report number, we do modify the it in our way). The generated report number will be show to you on the console, note it down!
   - Sample input: `202100001`
5. -p    intermediate <u>p</u>ath
   - [critical] [optional]
   - The intermediate file location for the transmission between infres and exps.
   - If not given, we will set it to our current workspace.
   - Sample input: `./temp123.csv`
6. -n    identifier <u>n</u>ame
   - [just for display] [required]
   - The customer's name to display in the report.
   - Sample input: `Zhang_Sam`
7. -g    identifier <u>g</u>ender
   - [just for display] [required]
   - The customer's gender to display in the report.
   - Sample input: `male`

## Programming Language

- Shell Script
- Java
- Python
- Markdown

## Work-flow

### Bio-analysis Process

#### Preparation

```shell
user_path="./user$user_id"
mkdir "$user_path"
mkdir "$user_path/code"
mkdir "$user_path/data"

cp "/ENCRYPTED_PATH/user$user_id/data/${file_name}_1.fq.gz" "$user_path/data"
cp "/ENCRYPTED_PATH/user$user_id/data/${file_name}_2.fq.gz" "$user_path/data"
```

Under your current workspace, we will first create the required folders, namely ./user/code and ./user/data. and then, as required, as a precondition, your genome files in both directions have been located in the designated places we required on the server (for security reasons, please contact the project leader manually for the address). We will go to the designated place to find and copy your files to our working directory.  

Then, their is an important variable that you need to pay special attention to is the `rootdir` and `shellroot`. The former is used to tell our program the location of some necessary helper programs, such as the generate_scripts.sh that will be mentioned later, which is usually the relative address on deepomics system from the current task's directory to the module's static directory.  The latter specifies the location of the dynamic codes. This is passed to generate_scripts.sh that will be mentioned later to generate code segments to the specified location, and it is also used to tell subsequent runtime addresses.

#### Generate scripts

Our AutoRunShell will invoke the `generate_script.sh` to perform the detailed work.    

This helper script only ask for two parameter inputs:   `-l user_path` and `-n user_name`, for which the user path is something like `"./userXYZ"` while the file name is just a simple name like `R` or `NR` in our default folder.

This script will use one of its parent function called `AutoRunShell#fsizeJudge()` to judge the file size of those genetic files to be tested.  If the file size is good enough, we will promote to you `"AutoRunShell >> fsizeJudge >> GOOD DATA SIZE: Your filesize is greater than threshold. Go ahead and have a good day!"`. On the other hand, if the file size is smaller than the threshold we set, our shell will warning that `"AutoRunShell >> fsizeJudge >> SMALL DATA WARN: Your filesize is xxx, which is smaller than the threshold. Error may occur during the analysing process, consider disabling the filtering function!"`

**Special Debug Note**: Previously Ms S.Y. LI suggested to disable a01-filterfq process if the small size input file is detected, but we had tried that directly disable is not applicable because some afterwards processes are depend on the output result of the first process. *TODO*: Maybe set some filter parameter to make it pass more easilly is a better choice than directly disable it.

**However**, due to hierarchical relationships between processes, the child process is difficult to pass variables back to its parent process. We did make it come true using `mkfifo` or called "named pipe" on local delta2 server, but deepomics docker does not seems to support this operation. *TODO*: According to Ms L.J. CHE, the docker should be able to support multi-thread operating, so create child-thread may solve the variable not readable issue exists on child-process programming.

After all the work finished, a series of ready to run shell scripts will be generated into the folder of `$user_path/code/` directory, they are `a01-filterfq.sh`, `a02-mem.sh`, `a03-rmclean.sh`, `a04-sort.sh`, `a05-rmfixmate.sh`, `a06-markdup.sh`, `a07-bamindex.sh`, `a08-rmsort.sh`, `a09-realignercreator.sh`, `a10-realn.sh`, `a11-baserecal.sh`, `a12-printreads.sh`, `a13-hc.sh`, `a14-rmbaserecal.sh`, `a15-rmrealn.sh`, `a16-concat.sh`, `a17-vqsrsnp.sh`, `a18-applysnp.sh`, `a19-vqsrindel.sh`, `a20-applyindel.sh`, `a21-annovar-vcf.sh` the detailed bioanalysis information can be found at [Reference#GATK](##reference).

#### Detailed analysis process

For all the 21 generated scripts listed above, we will run them sequentially.    

However, noticed that running GATK process and tools with a wrong version may cause sever unexpected exceptions. In our program, we called a well-designed global function `AutoRunShell#loadAll()`  (shown below) to make sure all the required module are in the correct version.

```shell
loadAll () {
    echo "AutoRunShell >> Load all is now be called!" 
    module load gatk/3.8-0-java-1.8.0_144
    module load annovar/2019oct24-perl-5.30.2
}
```

**Special Debug Note**: In our experience, `a13-hc` and `a17-vqsrsnp` are two places that are often prone to failure. For the "Bad input: Values for ReadPosRankSum annotation not detected for ANY training variant in the input callset. VariantAnnotator may be used to add these annotation ERROR of `a17-vqsrsnp`, 

- We tried to delete the -an option (such as `-an ReadPosRankSum`) reported in error message and let it skip the analysis module, which was really helpful when experimenting with small dataset. However, when we changed to formal large gene data analysis after successful development, even if the deleted parameters were added back, there would be no problem. To sum up, deleting an option can solve some problems temporally, but the real cause of this problem is the size of data is too small. 
- In the above debug process, according to Ms S.Y. LI's instructions, we also spent a lot of time trying to solve the problem if we reduce the subsequent `-tranche` value sequence. However, when we reduced the original 100.0-99.9-... to 60.0-55.0 -... It still won't get any better. Perhaps this is not as convenient as following the above mentioned solution.

#### Special Note

Deepomics' default memory allocation is not nearly enough to complete the entire bioanalysis process! The maximum memory limit of 8000MB caused a fatal error in the analysis process at the second step, but the error didn't show up until the last 10 steps, which was a serious hindrance to our debugging. Therefore, our team recommends that you set your maximum memory allocation limit to **<u>20480MB (20GB)</u>**, which will be sufficient to allow you to complete your entire process.

In addition, given GATK's excellent multi-core concurrency, properly setting up multiple CPU cores will greatly increase your work speed (as long as the server administrator allows, of course, otherwise it will take up too much resources and affect others' work).

If you want to know more about the resource usage of other analysis modules, you can use this link, [Deepomics API test](https://homepage.cs.cityu.edu.hk/jiakaixu2/php/deepomicsRequest.php?start=0&end=1). You need to change 0 to the start ID you want and set 1 to the end ID you want in the URL, which can batch query the resource application amount of all blocks within the range of start~end. Click the corresponding link in that row, and you can also use ALEX's CodeCoreProcessor to view the details of json inside it. Here's an example: [Module 700~730](https://homepage.cs.cityu.edu.hk/jiakaixu2/php/deepomicsRequest.php?start=700&end=730).

### Report Generation Process

Given that we're supposed to have done all the biological analysis by this point, why are we still hesitating? Let's move on to generating the test report. The overall task of this part is to translate the VCF files analyzed by the algorithm into a user-friendly PDF or HTML page.

#### Transition 

In this part, we handle all the required operations to transfer from the previous Bio-analysis Process to this Report Generation Process.

First, we copy all the required files from the module's static code area into the current project directory. This mainly includes some external files that infres and exps must use. After this comes the very important data file transfer. We first use `gzip -dk` to extract the final ".vcf.gz" file generated by the bioanalysis module into a ".vcf" format that infres can recognize and `mv` move the file to a directory that infres can read easily. Although there are many options we can choose, such as telling the infres the relative address of this vcf file so that it can find and read it, but given the relative integrity of infres python module installed and my familiarity with the Linux shell language, I think it's much more safer to unify the related files through the shell while keeping the IO stream of infres relatively fixed.

#### Generate json

Our AutoRunShell will invoke the `generate_json.sh` to perform the detailed work.    

This helper script ask for several parameter inputs:   `-k report_number`, `-v vcf_location`, `-p intermediate_path`, `-n identifier_name`, `-i identifier_id` and `-g identifier_gender`, although it seems the parameters are relative too complex to memorize clearly, it is because we need to display all the user own information onto the report, for which we have no way to create by ourselves, fortunately, all the meanings of those input parameters can be found at [Parameters](##parameters) (please check their name and meaning, since they are two independent processes, we tried our best to make sure they have the same prefix, but we are not guarantee about that).

This program will generate two required JSON files for infres and exps to facilitate their reading and operation, and the specific file format is set up in this code by ourselves, and it is unable to dynamically adjust its format, specific reasons will be discussed in the "Special Debug Note" part later.

As for the JSON file for infres, it is quite simple like the following (reformatted by Alex's CodeCoreProcessor),

```json
{
    "analysis": "annotate_variant_vcf",
    "intermediate_path": "./temp123.csv",
    "samples": [
        {
            "id": 1,
            "vcf_file": "./test/data.anno.hg38_multianno.vcf"
        }
    ]
}
```

While the JSON file for exps is a little bit complicated, since it contians so many user information that needs to pass. A sample JSON is like the following (reformatted by Alex's CodeCoreProcessor),

```json
{
    "product_name": "child genetic test",
    "operator": "./report/operators/rare_disease_operator.op",
    "template_path": "rare_disease_CHN/base/base.html",
    "template_loader_path": "./report/templates",
    "intermediate_path": "./temp123.csv",
    "analysis": "annotate_variant_vcf",
    "output_path_html": "./output/child/html/202100001.html",
    "output_path_pdf": "../output/202100001.pdf",
    "report_num": "202100001",
    "phone_num": "",
    "referring_docter": "",
    "report_time": "2021-11-18",
    "language": "CHN",
    "sample_infos": [
        {
            "identifier_name": "Zhang_Sam",
            "identifier_id": 1,
            "identifier_gender": "male",
            "identifier_birthday": "",
            "identifier_region": "",
            "sample_type": "",
            "sample_receive_ensure_time": "",
            "sample_receive_time": ""
        }
    ]
}
```

**Special Debug Note**: In the beginning, we do hope to maintain a concise and normative template layout, so in the first version, we use a unified template JSON file, and used [`sed -i`](##reference) command to replace the key points inside the template to make a new target file. It works really well if we just need to provide the user information and some time stamp. However, when we come to the directory input, namely those intermediate_path or the vcf_location, we meet a trouble,  sed command use "/" as its internal key separator to locate the matching point and the targeted new segment, where the "/" is also must character inside our directory string, we did try to use escape character, but it does not work well.

#### infres

"infres" stand for "**Information Reserve System**"

The infres system is a Python program that reads VCF files generated by biological analysis and adjusts and integrates them based on relevant guidelines. 

This program was previously developed by other seniors, but due to its relatively messy design and strong dependence on the PostgreSQL database, we were required to re-develop it in this project. Miss Yuqin HUANG in our project team bravely assumed the responsibility and undertook all the development work of this part alone. We would also like to thank Mr. Xuedong WANG and Mr. Zicheng ZHAO for their help in dealing with some difficulties.

Since we have develop and install this python program under a Python 3.8 environment, a temporary module change will be needed before infres core process using the command,

```shell
module load python/3.8.2
```

And the core invoking command is like,

```shell
infres process -i JSON_LOCATION
```

#### exps

"exps" stand for "**Express System**"

Exps is a Python program that reads CSV files that have been processed by Infres, looking up the relative gene' and disorders' datafile, generates HTML web pages based on a given template, and saves them into a portable PDF format. 

This program was previously developed by other seniors, but due to its relatively messy design and strong dependence on the PostgreSQL database, we were required to re-develop it in this project. Mr. Xun ZHANG and Mr. Jiakai XU in our project team undertook this part of the development work. We would also like to thank Mr. Bowen TAN and Mr. Xuedong WANG for their great help in dealing with some difficulties.

Since we have develop and install this python program under a Python 3.8 environment, a temporary module change will be needed before exps core process using the command,

```shell
module load python/3.8.2
```

At the same time, a file copy using `cp` is also needed to move the intermediate csv file from infres working space to exps working space.

And the core invoking command is like,

```shell
exps -i JSON_LOCATION -c INI_LOCATION
```

### Ending

This is the end of the work-flow, and if all goes well, you will find the final detection report generated in the task workspace environment in the corresponding location you set up, such as in the output folder. In future commercial applications, if some files are confirmed to be no longer needed, we can conduct unified storage and sorting here to make the server friendly.

It's time to say goodbye to you, and our AutoRunShell will promote you of the total time spent so far and say a sincere "Bye~" to you.

## Reference

[Deepomics <https://deepomics.org>](https://deepomics.org/)

[GATK <https://gatk.broadinstitute.org/hc/en-us>](https://gatk.broadinstitute.org/hc/en-us)

[Linux sed <https://www.gnu.org/software/sed/manual/sed.htm>](https://www.gnu.org/software/sed/manual/sed.htm)

