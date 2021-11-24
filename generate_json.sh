#!/bin/bash

# Variable declaration
report_num=
identifier_name=
identifier_id=
intermediate_path=
identifier_gender=

usage () {
    echo "This script is to generate template.json for the use of infres and exps."
    echo "Usage: $0 -k <key> -v <vcf_location> -p <intermediate_path> -n <name> -i <id> -g <gender>"
    echo "-----"
    echo "Ask Alex for further help."
}

while [ "$1" != "" ]
do
    case $1 in
        -k )
            shift
            report_num=$1
            ;;
        -v )
            shift
            vcf_location=$1
            ;;
        -p )
            shift
            intermediate_path=$1
            ;;
        -n )
            shift
            identifier_name=$1
            ;;
        -i )
            shift
            identifier_id=$1
            ;;
        -g )
            shift
            identifier_gender=$1
            ;;
    esac
    shift
done

if [ "$vcf_location" == "" ]; then
    echo
    echo "-v required"
    usage
    exit
fi

if [ "$report_num" == "" ]; then
    echo "-k required"
    usage
    exit
fi

if [ "$identifier_name" == "" ]; then
    echo "-n required"
    usage
    exit
fi

if [ "$identifier_id" == "" ]; then
    echo "-i required"
    usage
    exit
fi

if [ "$identifier_gender" == "" ]; then
    echo "-g required"
    usage
    exit
fi

if [ "$intermediate_path" == "" ]; then
    echo "-p required"
    usage
    exit
fi

report_time=$(date "+%Y-%m-%d")

echo
echo "Report $report_num will be generated on $report_time "
echo "$identifier_name (id: $identifier_id ), $identifier_gender"

echo
echo "Infres ==========>"
# cp infres_template.json template-g.json
# sed -i "s/\"intermediate_path\":.*$/\"intermediate_path\":\"$intermediate_path\",/g" template-g.json
# sed -i "s/\"id\":.*$/\"id\":$identifier_id,/g" template-g.json
# sed -i "s/\"vcf_file\":.*$/\"vcf_file\":\"$vcf_location\"/g" template-g.json
echo "{\"analysis\": \"annotate_variant_vcf\", \"intermediate_path\": \"$intermediate_path\", \"samples\": [{\"id\": $identifier_id, \"vcf_file\": \"$vcf_location\" }]}" >> tmp1.txt
newFileNameI="templateInfres-${report_num}.json"
mv tmp1.txt $newFileNameI

echo
echo "Finish editing, now display $newFileNameI ==========>"
cat $newFileNameI

echo
echo "Exps ==========>"
# cp exps_template.json template-t.json
# sed -i "s/\"report_num\":.*$/\"report_num\":\"$report_num\",/g" template-t.json
# sed -i "s/KEYHERE/$report_num/g" template-t.json
# sed -i "s/\"intermediate_path\":.*$/\"intermediate_path\":\"$intermediate_path\",/g" template-t.json
# sed -i "s/\"report_time\":.*$/\"report_time\":\"$report_time\",/g" template-t.json
# sed -i "s/\"identifier_name\":.*$/\"identifier_name\":\"$identifier_name\",/g" template-t.json
# sed -i "s/\"identifier_id\":.*$/\"identifier_id\":$identifier_id,/g" template-t.json
# sed -i "s/\"identifier_gender\":.*$/\"identifier_gender\":\"$identifier_gender\",/g" template-t.json
echo "{\"product_name\": \"child genetic test\", \"operator\": \"./report/operators/rare_disease_operator.op\", \"template_path\": \"rare_disease_CHN/base/base.html\", \"template_loader_path\": \"./report/templates\", \"intermediate_path\": \"$intermediate_path\", \"analysis\": \"annotate_variant_vcf\", \"output_path_html\": \"./output/child/html/$report_num.html\", \"output_path_pdf\": \"../output/$report_num.pdf\", \"report_num\": \"$report_num\", \"phone_num\": \"\", \"referring_docter\": \"\", \"report_time\": \"$report_time\", \"language\": \"CHN\", \"sample_infos\": [{ \"identifier_name\": \"$identifier_name\", \"identifier_id\": $identifier_id, \"identifier_gender\": \"$identifier_gender\", \"identifier_birthday\": \"\", \"identifier_region\": \"\", \"sample_type\": \"\", \"sample_receive_ensure_time\": \"\", \"sample_receive_time\": \"\" }]}" >> tmp2.txt
newFileNameE="templateExps-${report_num}.json"
mv tmp2.txt $newFileNameE

echo
echo "Finish editing, now display $newFileNameE ==========>"
cat $newFileNameE

exit
