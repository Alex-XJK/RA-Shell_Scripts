#!/bin/bash

# Variable declaration
echo "AutoRunShell >> Parameter check"
user_id=
filename=
report_num=
intermediate_path=
identifier_name=
identifier_gender=

currentDir=$(pwd)
vcf_location="./test/data.anno.hg38_multianno.vcf"

while [ "$1" != "" ]
do
    case $1 in
        -i )
            shift
            user_id=$1
            identifier_id=$user_id
            ;;
        -f )
            shift
            file_name=$1
            ;;
        -k )
            shift
            report_num=$1
            ;;
        -p )
            shift
            intermediate_path=$1
            ;;
        -n )
            shift
            identifier_name=$1
            ;;
        -g )
            shift
            identifier_gender=$1
            ;;
    esac
    shift
done

# Default value and warning

if [ "$user_id" == "" ]; then
    echo "-i required!"
fi

if [ "$file_name" == "" ]; then
    echo "-f required!"
fi

if [ "$identifier_name" == "" ]; then
    echo "-n required"
    exit
fi

if [ "$identifier_gender" == "" ]; then
    echo "-g required"
    exit
fi

if [ "$intermediate_path" == "" ]; then
    echo "'-p' not found, the system default version is applied."
    intermediate_path=$currentDir
    echo "your intermediate path is set to <$intermediate_path>"
fi

if [ "$report_num" == "" ]; then
    echo "'-k' not found, the system default version is applied."
    report_num=$(date "+%Y%m%d%H%d%M%S")
    echo "your key is set to <$report_num>"
fi

echo "AutoRunShell >> Parameter Display Start" 
echo " || -i : user_id ==> $user_id"
echo " ||    : identifier_id ==> $identifier_id"
echo " || -f : file_name ==> $file_name"
echo " || -k : report_num ==> $report_num"
echo " || -p : intermediate_path ==> $intermediate_path"
echo " || -n : identifier_name ==> $identifier_name"
echo " || -g : identifier_gender ==> $identifier_gender"
echo " || -v : vcf_location ==> $vcf_location"
echo "AutoRunShell >> Parameter Display End" 


echo "AutoRunShell >> Start coping required files" 
user_path="./user$user_id"
mkdir "$user_path"
mkdir "$user_path/code"
mkdir "$user_path/data"

cp "/disk2/workspace/platform/gapp/user$user_id/data/${file_name}_1.fq.gz" "$user_path/data"
cp "/disk2/workspace/platform/gapp/user$user_id/data/${file_name}_2.fq.gz" "$user_path/data"


# Variables setting
rootdir="../../../workspace/offline/GAPP_workflow"
shellroot="$user_path/code"

# Start up variables
current_time=$(date "+%Y%m%d-%H%M%S")
sta_total=`date +%s`
isSmallFile="0"

# Function block
shellVersion () {
    echo "AutoRunShell >> @param    -deepomics  Online used only." 
    echo "AutoRunShell >> @param    -t          Do the timing." 
    echo "AutoRunShell >> @param    -e          STDERR is redirected to STDOUT for some key pathway." 
    echo "AutoRunShell >> @version  deepomics 3.1" 
    echo "AutoRunShell >> @since    Nov. 19, 2021" 
}

loadAll () {
    echo "AutoRunShell >> Load all is now be called!" 
    module load gatk/3.8-0-java-1.8.0_144
    module load annovar/2019oct24-perl-5.30.2
}

printDir () {
    echo "AutoRunShell >> Current Directory" 
    pwd 
}

blankLine () {
    echo " "
    echo " "
    echo " ========== ~\(≧▽≦)/~ ========== "
    echo " "
    echo " "
}

systemDirInfo () {
    echo "AutoRunShell >> Current user: ${USER} (id: ${UID})" 
    echo "AutoRunShell >> Generate Scripts shell is located at: ${rootdir}" 
    echo "AutoRunShell >> All the remaining work shell are located at: ${shellroot}" 
}

fsizeJudge () {
    let threshold=3000000000

    let tfsize=$(ls -l $1 | awk '{print $5}')
    if [ "$tfsize" -gt "$threshold" ]; then
        echo "AutoRunShell >> fsizeJudge >> Now checking file $1"
        echo -e  "AutoRunShell >> fsizeJudge >> \t\t $(ls -l $1)"
        echo "AutoRunShell >> fsizeJudge >> GOOD DATA SIZE: Your filesize is $tfsize greater than threshold ($threshold). Go ahead and have a good day!"
    else
        echo "AutoRunShell >> fsizeJudge >> Now checking file $1"
        echo -e "AutoRunShell >> fsizeJudge >> \t\t $(ls -l $1)"
        echo "AutoRunShell >> fsizeJudge >> SMALL DATA WARN: Your filesize is $tfsize, which is smaller than the threshold ($threshold). Error may occur during the analysing process, consider disabling the filtering function!"
        isSmallFile="1"
    fi
}

# Export the functions to global so that child process can use them.
export -f loadAll fsizeJudge 

# Welcome
echo -e "AutoRunShell >> Welcome!" 
shellVersion

# Display system time
echo -e "AutoRunShell >> System Time ${current_time}" 

# Display current path
printDir

# Display files' locations
systemDirInfo

blankLine

# a00-Generate Scripts
echo "AutoRunShell >> generate_script.sh" 
sta_tmp=`date +%s`
bash $rootdir/generate_script.sh -l $user_path -n $file_name
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo "AutoRunShell >> generate_script ~ ${dif_tmp} seconds" 

blankLine

# Display current path
printDir

blankLine

# a01 run switcher
isSmallFile="0" # comment this to enable a01 or auto judge
echo "DEBUG >> is_small? $isSmallFile"

# a01-filterfq
echo "AutoRunShell >> a01" 
sta_tmp=`date +%s`

loadAll
sh $shellroot/a01-filterfq.sh 2>&1

end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo "AutoRunShell >> a01-filterfq ~ ${dif_tmp} seconds" 

blankLine

# a02-mem
echo "AutoRunShell >> a02" 
sta_tmp=`date +%s`
loadAll
sh $shellroot/a02-mem.sh 2>&1
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo "AutoRunShell >> a02-mem ~ ${dif_tmp} seconds" 

blankLine

# a03-rmclean
echo "AutoRunShell >> a03" 
sta_tmp=`date +%s`
loadAll
sh $shellroot/a03-rmclean.sh 2>&1
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo "AutoRunShell >> a03-rmclean ~ ${dif_tmp} seconds" 

blankLine

# a04-sort
echo "AutoRunShell >> a04" 
sta_tmp=`date +%s`
loadAll
sh $shellroot/a04-sort.sh 2>&1
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo "AutoRunShell >> a04-sort ~ ${dif_tmp} seconds" 

blankLine

# a05-rmfixmate
echo "AutoRunShell >> a05" 
sta_tmp=`date +%s`
loadAll
sh $shellroot/a05-rmfixmate.sh 2>&1
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo "AutoRunShell >> a05-rmfixmate ~ ${dif_tmp} seconds" 

blankLine

# a06-markdup
echo "AutoRunShell >> a06" 
sta_tmp=`date +%s`
loadAll
sh $shellroot/a06-markdup.sh 2>&1
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo "AutoRunShell >> a06-markdup ~ ${dif_tmp} seconds" 

blankLine

# a07-bamindex
echo "AutoRunShell >> a07" 
sta_tmp=`date +%s`
loadAll
sh $shellroot/a07-bamindex.sh 2>&1
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo "AutoRunShell >> a07-bamindex ~ ${dif_tmp} seconds" 

blankLine

# a08-rmsort
echo "AutoRunShell >> a08" 
sta_tmp=`date +%s`
loadAll
sh $shellroot/a08-rmsort.sh 2>&1
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo "AutoRunShell >> a08-rmsort ~ ${dif_tmp} seconds" 

blankLine

# a09-realignercreator
echo "AutoRunShell >> a09" 
sta_tmp=`date +%s`
loadAll
sh $shellroot/a09-realignercreator.sh 2>&1
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo "AutoRunShell >> a09-realignercreator ~ ${dif_tmp} seconds" 

blankLine

# a10-realn
echo "AutoRunShell >> a10" 
sta_tmp=`date +%s`
loadAll
sh $shellroot/a10-realn.sh 2>&1
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo "AutoRunShell >> a10-realn ~ ${dif_tmp} seconds" 

blankLine

# a11-baserecal
echo "AutoRunShell >> a11" 
sta_tmp=`date +%s`
loadAll
sh $shellroot/a11-baserecal.sh 2>&1
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo "AutoRunShell >> a11-baserecal ~ ${dif_tmp} seconds" 

blankLine

# a12-printreads
echo "AutoRunShell >> a12" 
sta_tmp=`date +%s`
loadAll
sh $shellroot/a12-printreads.sh 2>&1
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo "AutoRunShell >> a12-printreads ~ ${dif_tmp} seconds" 

blankLine

# a13-hc
echo "AutoRunShell >> a13" 
sta_tmp=`date +%s`
loadAll
sh $shellroot/a13-hc.sh 2>&1
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo "AutoRunShell >> a13-hc ~ ${dif_tmp} seconds" 

blankLine

# a14-rmbaserecal
echo "AutoRunShell >> a14" 
sta_tmp=`date +%s`
loadAll
sh $shellroot/a14-rmbaserecal.sh 2>&1
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo "AutoRunShell >> a14-rmbaserecal ~ ${dif_tmp} seconds" 

blankLine

# a15-rmrealn
echo "AutoRunShell >> a15" 
sta_tmp=`date +%s`
loadAll
sh $shellroot/a15-rmrealn.sh 2>&1
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo "AutoRunShell >> a15-rmrealn ~ ${dif_tmp} seconds" 

blankLine

# a16-concat
echo "AutoRunShell >> a16" 
sta_tmp=`date +%s`
loadAll
sh $shellroot/a16-concat.sh 2>&1
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo "AutoRunShell >> a16-concat ~ ${dif_tmp} seconds" 

blankLine

# a17-vqsrsnp
echo "AutoRunShell >> a17" 
sta_tmp=`date +%s`
loadAll
sh $shellroot/a17-vqsrsnp.sh 2>&1
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo "AutoRunShell >> a17-vqsrsnp ~ ${dif_tmp} seconds" 

blankLine

# a18-applysnp
echo "AutoRunShell >> a18" 
sta_tmp=`date +%s`
loadAll
sh $shellroot/a18-applysnp.sh 2>&1
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo "AutoRunShell >> a18-applysnp ~ ${dif_tmp} seconds" 

blankLine

# a19-vqsrindel
echo "AutoRunShell >> a19" 
sta_tmp=`date +%s`
loadAll
sh $shellroot/a19-vqsrindel.sh 2>&1
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo "AutoRunShell >> a19-vqsrindel ~ ${dif_tmp} seconds" 

blankLine

# a20-applyindel
echo "AutoRunShell >> a20" 
sta_tmp=`date +%s`
loadAll
sh $shellroot/a20-applyindel.sh 2>&1
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo "AutoRunShell >> a20-applyindel ~ ${dif_tmp} seconds" 

blankLine

# a21-annovar-vcf
echo "AutoRunShell >> a21" 
sta_tmp=`date +%s`
loadAll
sh $shellroot/a21-annovar-vcf.sh 2>&1
end_tmp=`date +%s`
let dif_tmp=($end_tmp - $sta_tmp)
echo "AutoRunShell >> a21-annovar-vcf ~ ${dif_tmp} seconds" 

blankLine

# Finishing up
echo "AutoRunShell >> Finished" 

blankLine

end_total=`date +%s`
let dif_total=($end_total - $sta_total)
echo "AutoRunShell >> The whole analysis process spend ${dif_total} seconds to run" 

blankLine


##########################################################################################


echo "AutoRunShell >> Start Generating Report at $(pwd)"
sta_report=`date +%s`

blankLine

# Copy required files to this project
echo "AutoRunShell >> Copy required files"
mkdir infres
mkdir exps
mkdir output
cp ../../../workspace/offline/GAPP_workflow/generate_json.sh ./
cp -R ../../../workspace/offline/GAPP_workflow/infres/* ./infres
cp -R ../../../workspace/offline/GAPP_workflow/exps/* ./exps

blankLine


echo "AutoRunShell >> Transition from bio-analyse to report generation"
gzip -dk $user_path/data/snp/data.anno.hg38_multianno.vcf.gz
mv $user_path/data/snp/data.anno.hg38_multianno.vcf ./infres/test/data.anno.hg38_multianno.vcf

blankLine


# Generate JSON first
echo "AutoRunShell >> Generate JSONs"
echo "AutoRunShell >> $(pwd) >> sh ./generate_json.sh -k $report_num -v $vcf_location -p $intermediate_path -n $identifier_name -i $identifier_id -g $identifier_gender"
sh ./generate_json.sh -k $report_num -v $vcf_location -p $intermediate_path -n $identifier_name -i $identifier_id -g $identifier_gender

jsonInfresLocs="${currentDir}/templateInfres-${report_num}.json"
jsonExpsLocs="${currentDir}/templateExps-${report_num}.json"

blankLine

# Infres now
echo "AutoRunShell >> Prepare infres"
cd ./infres
module load python/3.8.2

echo "AutoRunShell >> Core infres"
echo "AutoRunShell >> $(pwd) >> infres process -i $jsonInfresLocs"
infres process -i $jsonInfresLocs 2>&1

blankLine

# Exps now
echo "AutoRunShell >> Prepare exps"
echo "AutoRunShell >> $(pwd) >> cp $currentDir/infres/$intermediate_path $currentDir/exps/$intermediate_path"
cp $currentDir/infres/$intermediate_path $currentDir/exps/$intermediate_path
cd ../exps
module load python/3.8.2

echo "AutoRunShell >> Core exps"
echo "AutoRunShell >> $(pwd) >> exps -i $jsonExpsLocs -c ./report/templates/rare_disease_CHN/test.ini"
exps -i $jsonExpsLocs -c ./report/templates/rare_disease_CHN/test.ini 2>&1

blankLine

end_report=`date +%s`
let dif_report=($end_report - $sta_report)
echo "AutoRunShell >> The whole report generate process spend ${dif_report} seconds to run" 

# Display finished system time
finished_time=$(date "+%Y%m%d-%H%M%S")
echo "AutoRunShell >> System Time ${finished_time}" 

# Bye
echo "AutoRunShell >> Bye~" 
