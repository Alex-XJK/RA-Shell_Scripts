# echo "Check Point -1: Server Check!"
# echo "Current Loca: $(pwd)"
# echo "Current User: ${USER} (id: ${UID})"
# echo "Current PATH: ${PATH}"
# echo "Current DirF: $(ls)"
# echo " "

while [ "$1" != "" ]
do
    case $1 in
        -l )
            shift
            user_path=$1
            ;;
        -n )
            shift
            file_name=$1
            ;;

    esac
    shift
done

echo "Check Point 0: Begin of whole script!"
# mkdir ./user1
# mkdir ./user1/code
# mkdir ./user1/data

# cp /disk2/workspace/platform/gapp/user1/data/NR_1.fq.gz ./user1/data/NR_1.fq.gz
# cp /disk2/workspace/platform/gapp/user1/data/NR_2.fq.gz ./user1/data/NR_2.fq.gz
# cp /disk2/workspace/platform/gapp/user1/data/R_1.fq.gz ./user1/data/R_1.fq.gz
# cp /disk2/workspace/platform/gapp/user1/data/R_2.fq.gz ./user1/data/R_2.fq.gz
# cp /disk2/workspace/platform/gapp/user1/data/SR_1.fq.gz ./user1/data/SR_1.fq.gz
# cp /disk2/workspace/platform/gapp/user1/data/SR_2.fq.gz ./user1/data/SR_2.fq.gz

# module.load
module load gatk/3.8-0-java-1.8.0_144
module load annovar/2019oct24-perl-5.30.2

# source /home/_00_ROOT_THINGS/_00_Global_Variables.sh
filterfq=/home/BIOINFO_TOOLS/rawdata_tools/filterfq/filterfq
bwa=/home/BIOINFO_TOOLS/alignment_tools/BWA/BWA-0.7.17/bwa
samtools=/home/BIOINFO_TOOLS/mutation_tools/SamTools/SamTools-1.9/samtools
gatk=/disk2/apps/software/GATK/3.8-0-Java-1.8.0_144/GenomeAnalysisTK.jar
picard=/home/BIOINFO_TOOLS/alignment_tools/Picard/picard-tools-2.1.0/picard.jar
bcftools=/home/BIOINFO_TOOLS/mutation_tools/bcftools/bcftools-1.9/bcftools
ref=/home/BIOINFO_DATABASE/reference/genome_DNA/Homo_sapiens/hg38/BWA_GATK_index/hg38.fa
pigz=/disk2/workspace/platform/gapp/dependence/pigz
temp_dir="$user_path/temp_dir"
# gatk_bundle=/mnt/beta/USERS/zhaozc/database/GATK_bundle/hg38
annovar=/disk2/apps/software/annovar/2019Oct24-foss-2020a-Perl-5.30.2/table_annovar.pl
annovar_db_hg38=/disk2/workspace/platform/gapp/dependence/humandb
hapmap=/home/BIOINFO_DATABASE/hapmap/Homo_sapiens/hapmap_3.3/GRCh38/hapmap_3.3.hg38.vcf.gz
omini=/home/BIOINFO_DATABASE/omni_1000G/omni2.5/GRCh38/1000G_omni2.5.hg38.vcf.gz
G1000=/disk2/workspace/platform/gapp/dependence/1000G_phase1.snps.high_confidence.hg38.vcf.gz
dbsnp=/home/BIOINFO_DATABASE/dbSNP/dbSNP_150/Homo_sapiens/GRCh38/dbSNP_150_hg38.common.prefixChr.vcf.bgz
mills=/disk2/workspace/platform/gapp/dependence/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz
# sample_root_dir=./user2/data
# script_dir=./user2/code
# sample_run_list=./user2/srl.list
sample_root_dir=$user_path
script_dir="$user_path/code"
# sample_run_list=/disk2/workspace/platform/gapp/user1/srl.list

echo "GenerateScript >> Self_Directory_Checking ... starting ..."
echo " "
echo "GenerateScript >> Absolute Address (Should not have any ERROR)"
ls -l $filterfq
ls -l $bwa
ls -l $samtools
ls -l $gatk
ls -l $picard
ls -l $bcftools
ls -l $ref
ls -l $pigz
# ls -l $gatk_bundle
ls -l $annovar
ls -l $annovar_db_hg38
ls -l $hapmap
ls -l $omini
ls -l $G1000
ls -l $dbsnp
ls -l $mills
echo " "
echo "GenerateScript >> Relative Address (Just for checking)"
ls -l $temp_dir
ls -l $sample_root_dir
ls -l $script_dir
echo "GenerateScript >> Self_Directory_Checking ... finished ..."

echo "Check Point 1: Finish reading dirs!"

# usage () {
#     echo "This script is to generate command lines for sequencing data preprocessing, alignment, variation calling and sv calling."
#     echo "Usage: $0 -l <sample_run_list> -d <sample_root_dir> -s <script_dir>"
# }


# if [ "$sample_run_list" == "" ]; then
#     echo "-l required"
#     usage
#     exit
# fi

# if [ "$sample_root_dir" == "" ]; then
#     echo "-d required"
#     usage
#     exit
# fi

# if [ "$script_dir" == "" ]; then
#     echo "-s required"
#     usage
#     exit
# fi

# if [ "$ref" == "" ]; then
#     echo "-r required"
#     usage
#     exit
# fi

echo "Check Point 2: Finish checking params!"

rm -f $script_dir/*

    sample="data"
    run=$file_name
    mnt=$user_path
    if [ ! -d $sample_root_dir/$sample ]; then
        mkdir $sample_root_dir/$sample
    fi
    if [ ! -d $sample_root_dir/$sample/aln ]; then
        mkdir $sample_root_dir/$sample/aln
    fi
    if [ ! -d $sample_root_dir/$sample/snp ]; then
        mkdir $sample_root_dir/$sample/snp
    fi
    if [ ! -d $sample_root_dir/$sample/phase ]; then
        mkdir $sample_root_dir/$sample/phase
    fi
    # align
    echo "GenerateScript >> Print out params"
    echo "GenerateScript >> [:mnt] $mnt"
    echo "GenerateScript >> [:sample] $sample"
    echo "GenerateScript >> [:run] $run"
    
    # check user data file exists
    echo "check user data file exists"
    ls -l $mnt/$sample/${run}_1.fq.gz
    ls -l $mnt/$sample/${run}_2.fq.gz
    fsizeJudge $mnt/$sample/${run}_1.fq.gz
    fsizeJudge $mnt/$sample/${run}_2.fq.gz

    # for run with adapters
    # echo "$filterfq -f $mnt/$sample/${run}_1.fq.gz $mnt/$sample/${run}_2.fq.gz -a $mnt/$sample/1.adapter.list.gz $mnt/$sample/2.adapter.list.gz -L 150 -O $sample_root_dir/$sample/aln -o $run" > $script_dir/$sample.filterfq.sh
    # for run without adapters
    echo "$filterfq -f $mnt/$sample/${run}_1.fq.gz $mnt/$sample/${run}_2.fq.gz -O $sample_root_dir/$sample/aln -o $run" >> $script_dir/a01-filterfq.sh
    # echo "$filterfq -f $mnt/$sample/${run}.R1.clean.fastq.gz $mnt/$sample/${run}.R2.clean.fastq.gz -O $sample_root_dir/$sample/aln -o $run" >> $script_dir/a01-filterfq.sh
    echo "$bwa mem -t 8 -Y -M -R '@RG\tID:$run\tLB:$sample\tPL:illumina\tCN:null\tPU:$run\tSM:$sample\tTS:MHC\tIV:$sample' $ref $sample_root_dir/$sample/aln/${run}_1.clean.fastq.gz $sample_root_dir/$sample/aln/${run}_2.clean.fastq.gz | $samtools view -F 0x800 -b -T $ref | $samtools sort --thread 8 -n | $samtools fixmate -O bam - $sample_root_dir/$sample/aln/$sample.fixmate.bam" >> $script_dir/a02-mem.sh
    # echo "$samtools fixmate $sample_root_dir/$sample/aln/$sample.fixmate.bam $sample_root_dir/$sample/aln/$sample.refix.bam" >> $script_dir/a02.1-refix.sh
    echo "rm -f $sample_root_dir/$sample/aln/$run*.fastq.gz" >> $script_dir/a03-rmclean.sh
    echo "$samtools sort --thread 8 $sample_root_dir/$sample/aln/$sample.fixmate.bam -o $sample_root_dir/$sample/aln/$sample.sort.bam" >> $script_dir/a04-sort.sh
    echo "rm -f $sample_root_dir/$sample/aln/$sample.fixmate.bam*" >> $script_dir/a05-rmfixmate.sh
    # echo "$samtools markdup -r $sample_root_dir/$sample/aln/$sample.sort.bam $sample_root_dir/$sample/aln/$sample.markdup.bam" >> $script_dir/a06-markdup.sh
    echo "java -Xmx5g -jar $picard MarkDuplicates I=$sample_root_dir/$sample/aln/$sample.sort.bam O=$sample_root_dir/$sample/aln/$sample.markdup.bam M=$sample_root_dir/$sample/aln/$sample.markdup.matrics TMP_DIR=$temp_dir" >> $script_dir/a06-markdup.sh
    echo "$samtools index $sample_root_dir/$sample/aln/$sample.markdup.bam" >> $script_dir/a07-bamindex.sh
    echo "rm -f $sample_root_dir/$sample/aln/$sample.sort.bam*" >> $script_dir/a08-rmsort.sh

    # lobstr
    # echo "$pigz -d -c -p 10 $sample_root_dir/$sample/aln/${run}_1.clean.fastq.gz > $sample_root_dir/$sample/aln/${run}_1.clean.fastq && $pigz -d -c -p 10 $sample_root_dir/$sample/aln/${run}_2.clean.fastq.gz > $sample_root_dir/$sample/aln/${run}_2.clean.fastq && $lobSTR --p1 $sample_root_dir/$sample/aln/${run}_1.clean.fastq --p2 $sample_root_dir/$sample/aln/${run}_2.clean.fastq -q -p 10 --index-prefix $biodb_human_lobSTR_hg19_prefix -o $sample_root_dir/$sample/aln/$sample.lobSTR --rg-sample $sample --rg-lib $run && rm $sample_root_dir/$sample/aln/${run}_1.clean.fastq $sample_root_dir/$sample/aln/${run}_2.clean.fastq" > $script_dir/$sample.lobSTR.sh
    # echo "$samtools sort --thread 10 $sample_root_dir/$sample/aln/$sample.lobSTR.aligned.bam -o $sample_root_dir/$sample/aln/$sample.lobSTR.sorted.bam" > $script_dir/$sample.lobSTR.sort.sh
    # echo "$samtools index $sample_root_dir/$sample/aln/$sample.lobSTR.sort.bam" > $script_dir/$sample.lobSTR.bamindex.sh
    # echo "$allelotype --command classify --bam $sample_root_dir/$sample/aln/$sample.lobSTR.sort.bam --noise_model $biodb_human_lobSTR_hg19_noise_model --out $sample_root_dir/$sample/aln/$sample.lobSTR --strinfo $biodb_human_lobSTR_hg19_tab --index-prefix $biodb_human_lobSTR_hg19_prefix" > $script_dir/$sample.allelotype.sh
    # echo "gzip $sample_root_dir/$sample/aln/$sample.lobSTR.vcf && $bcftools index $sample_root_dir/$sample/aln/$sample.lobSTR.vcf.gz" > $script_dir/$sample.strindex.sh
    # echo "gunzip $sample_root_dir/$sample/aln/$sample.lobSTR.vcf.gz && grep '^#' $sample_root_dir/$sample/aln/$sample.lobSTR.vcf > $sample_root_dir/$sample/aln/$sample.lobSTR.sorted.vcf && grep -v '^#' $sample_root_dir/$sample/aln/$sample.lobSTR.vcf | LC_ALL=C sort -t $'\t' -k1,1 -k2,2n >> $sample_root_dir/$sample/aln/$sample.lobSTR.sorted.vcf && bgzip $sample_root_dir/$sample/aln/$sample.lobSTR.sorted.vcf && tabix $sample_root_dir/$sample/aln/$sample.lobSTR.sorted.vcf.gz && rm $sample_root_dir/$sample/aln/$sample.lobSTR.vcf" > $script_dir/$sample.strindex.sh

    echo "java -Djava.io.tmpdir=$temp_dir -Xmx5g -jar $gatk -T RealignerTargetCreator -R $ref -I $sample_root_dir/$sample/aln/$sample.markdup.bam -o $sample_root_dir/$sample/aln/$sample.intervals" >> $script_dir/a09-realignercreator.sh
    echo "java -Djava.io.tmpdir=$temp_dir -Xmx5g -jar $gatk -T IndelRealigner -R $ref -I $sample_root_dir/$sample/aln/$sample.markdup.bam -o $sample_root_dir/$sample/aln/$sample.realn.bam -targetIntervals $sample_root_dir/$sample/aln/$sample.intervals -maxInMemory 300000 -l INFO" >> $script_dir/a10-realn.sh

    # base recalibration
    echo "java -Djava.io.tmpdir=$temp_dir -Xmx5g -jar $gatk -T BaseRecalibrator -R $ref -I $sample_root_dir/$sample/aln/$sample.realn.bam -knownSites $dbsnp -o $sample_root_dir/$sample/aln/$sample.baserecal.prior.table" >> $script_dir/a11-baserecal.sh
    echo "java -Djava.io.tmpdir=$temp_dir -Xmx5g -jar $gatk -T PrintReads -R $ref -I $sample_root_dir/$sample/aln/$sample.realn.bam -BQSR $sample_root_dir/$sample/aln/$sample.baserecal.prior.table -o $sample_root_dir/$sample/aln/$sample.markdup.realn.baserecal.bam" >> $script_dir/a12-printreads.sh

    chrom=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y)
    # for chrom in "${chrom[@]}"; do
    #     echo "java -Djava.io.tmpdir=$temp_dir -Xmx5g -jar $gatk -T HaplotypeCaller -R $ref -ERC GVCF -variant_index_type LINEAR -variant_index_parameter 128000 --dbsnp $dbsnp -A StrandOddsRatio -A Coverage -A QualByDepth -A FisherStrand -A MappingQualityRankSumTest -A ReadPosRankSumTest -A RMSMappingQuality -I $sample_root_dir/$sample/aln/$sample.markdup.realn.baserecal.bam -o $sample_root_dir/$sample/snp/$sample.chr"$chrom".g.vcf.gz -L chr"$chrom"" >> $script_dir/a13-hc.sh

    # single sample mode

    # haplotype caller by chromosome
    for chrom in "${chrom[@]}"; do
        echo "java -Djava.io.tmpdir=$temp_dir -Xmx5g -jar $gatk -T HaplotypeCaller -R $ref -variant_index_type LINEAR -variant_index_parameter 128000 --dbsnp $dbsnp -A StrandOddsRatio -A Coverage -A QualByDepth -A FisherStrand -A MappingQualityRankSumTest -A ReadPosRankSumTest -A RMSMappingQuality -I $sample_root_dir/$sample/aln/$sample.markdup.realn.baserecal.bam -o $sample_root_dir/$sample/snp/$sample.chr"$chrom".vcf.gz -L chr"$chrom"" >> $script_dir/a13-hc.sh
    done
    echo "rm -f $sample_root_dir/$sample/aln/$sample.markdup.realn.baserecal*" >> $script_dir/a14-rmbaserecal.sh
    echo "rm -f $sample_root_dir/$sample/aln/$sample.realn.*" >> $script_dir/a15-rmrealn.sh

    # merge chrom vcf
    echo "$bcftools concat -O z -o $sample_root_dir/$sample/snp/$sample.raw.vcf.gz $sample_root_dir/$sample/snp/$sample.chr*.vcf.gz && tabix $sample_root_dir/$sample/snp/$sample.raw.vcf.gz" >> $script_dir/a16-concat.sh
    # vqsr snp
    echo "java -Djava.io.tmpdir=$temp_dir -Xmx5g -jar $gatk -T VariantRecalibrator -R $ref -input $sample_root_dir/$sample/snp/$sample.raw.vcf.gz -resource:hapmap,known=false,training=true,truth=true,prior=15.0 $hapmap -resource:omini,known=false,training=true,truth=false,prior=12.0 $omini -resource:1000G,known=false,training=true,truth=false,prior=10.0 $G1000 -resource:dbsnp,known=true,training=false,truth=false,prior=6.0 $dbsnp -an DP -an QD -an FS -an SOR -an ReadPosRankSum -an MQRankSum -mode SNP -tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 95.0 -tranche 90.0 -recalFile $sample_root_dir/$sample/snp/$sample.snp.recal -tranchesFile $sample_root_dir/$sample/snp/$sample.snp.tranches -rscriptFile $sample_root_dir/$sample/snp/$sample.snp.plots.R" >> $script_dir/a17-vqsrsnp.sh
    echo "java -Djava.io.tmpdir=$temp_dir -Xmx5g -jar $gatk -T ApplyRecalibration -R $ref -input $sample_root_dir/$sample/snp/$sample.raw.vcf.gz --ts_filter_level 99.0 -tranchesFile $sample_root_dir/$sample/snp/$sample.snp.tranches -recalFile $sample_root_dir/$sample/snp/$sample.snp.recal -mode SNP -o $sample_root_dir/$sample/snp/$sample.snp.vcf.gz" >> $script_dir/a18-applysnp.sh
    # vqsr indel
    echo "java -Djava.io.tmpdir=$temp_dir -Xmx5g -jar $gatk -T VariantRecalibrator -R $ref -input $sample_root_dir/$sample/snp/$sample.snp.vcf.gz -resource:mills,known=true,training=true,truth=true,prior=12.0 $mills -resource:dbsnp,known=true,training=false,truth=false,prior=2.0 $dbsnp -an DP -an QD -an FS -an SOR -an ReadPosRankSum -an MQRankSum -mode INDEL -rscriptFile $sample_root_dir/$sample/snp/$sample.snp.indel.plots.R -tranchesFile $sample_root_dir/$sample/snp/$sample.snp.indel.tranches -recalFile $sample_root_dir/$sample/snp/$sample.snp.indel.recal" >> $script_dir/a19-vqsrindel.sh
    echo "java -Djava.io.tmpdir=$temp_dir -Xmx5g -jar $gatk -T ApplyRecalibration -R $ref -input $sample_root_dir/$sample/snp/$sample.snp.vcf.gz --ts_filter_level 99.0 -tranchesFile $sample_root_dir/$sample/snp/$sample.snp.indel.tranches -recalFile $sample_root_dir/$sample/snp/$sample.snp.indel.recal -mode INDEL -o $sample_root_dir/$sample/snp/$sample.snp.indel.vcf.gz" >> $script_dir/a20-applyindel.sh

    # annotate
    echo "$annovar $sample_root_dir/$sample/snp/$sample.snp.indel.vcf.gz $annovar_db_hg38 -buildver hg38 -out $sample_root_dir/$sample/snp/$sample.anno -protocol refGene,exac03,1000g2015aug_all,esp6500siv2_all,avsnp150,clinvar_20200316,dbnsfp35a -operation g,f,f,f,f,f,f -nastring . -vcfinput -polish && bgzip $sample_root_dir/$sample/snp/$sample.anno.hg38_multianno.vcf && tabix $sample_root_dir/$sample/snp/$sample.anno.hg38_multianno.vcf.gz" >> $script_dir/a21-annovar-vcf.sh

echo "Check Point 3: Finished generate and find generated file directory!"
find . -name "a01-filterfq.sh"
find . -name "a21-annovar-vcf.sh"

echo "Check Point 4: End of file!"
