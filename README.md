# Azure CycleCloud template for Genomics Pipeline Applications

## Prerequisites

1. Install CycleCloud CLI

## Install Software

These applications is installed automatically.

1. BWA
1. SAMTOOLS
1. htslib
1. GATK
1. Cromwell
1. Slurm
1. Docker, Singularity

## How to install 

1. tar zxvf cyclecloud-genomicswfe<version>.tar.gz
1. cd cyclecloud-genomicswfe<version>
1. Rewrite "Files" attribute for your binariy in "project.ini" file. 
1. run "cyclecloud project upload azure-storage" for uploading template to CycleCloud
1. "cyclecloud import_template -f templates/genomicswfe.txt" for register this template to your CycleCloud

## How to use

1. Download your sample
1. Create batch script 
1. Submit the job. "sbatch -c 44 -n 1 run.sh" (for example, HC44rs 1 node)

Sample Submit Script (run.sh) for bwa mem. (without WDL)
<pre><code>
CORE=44
time ~/apps/bwa-0.7.17/bwa mem -t $CORE -R <read group header> ~/apps/ucsc.hg19 ~/apps/GENOMICS_randomreads_R1.fastq ~/apps/GENOMICS_randomreads_R2.fastq > ~/apps/GENOMICS_randomreads.sam
</pre></code>

# Azure CycleCloud用テンプレート:Genomics向けアプリケーション、ワークフローエンジン

[Azure CycleCloud](https://docs.microsoft.com/en-us/azure/cyclecloud/) はMicrosoft Azure上で簡単にCAE/HPC/Deep Learning用のクラスタ環境を構築できるソリューションです。

![テンプレートがサポートするアプリケーション構成](https://raw.githubusercontent.com/hirtanak/scripts/master/GenomicsWFEDiagram.png "テンプレートがサポートするアプリケーション構成")

Azure CyceCloudのインストールに関しては、[こちら](https://docs.microsoft.com/en-us/azure/cyclecloud/quickstart-install-cyclecloud) のドキュメントを参照してください。

ゲノミクス向けパイプラインアプリケーションのテンプレートになっています。
以下の構成、特徴を持っています。

1. OSS PBS ProジョブスケジューラをMasterノードにインストール
2. H16r, H16r_Promo, HC44rs, HB60rsを想定したテンプレート、イメージ
         - OpenLogic CentOS 7.6 HPC を利用 
3. Masterノードに512GB * 2 のNFSストレージサーバを搭載
         - Executeノード（計算ノード）からNFSをマウント
4. MasterノードのIPアドレスを固定設定
         - 一旦停止後、再度起動した場合にアクセスする先のIPアドレスが変更されない

![OSS PBS Default テンプレート構成](https://raw.githubusercontent.com/hirtanak/osspbsdefault/master/OSSPBSDefaultDiagram.png "OSS PBS Default テンプレート構成")

テンプレートインストール方法

前提条件: テンプレートを利用するためには、Azure CycleCloud CLIのインストールと設定が必要です。詳しくは、 [こちら](https://docs.microsoft.com/en-us/azure/cyclecloud/install-cyclecloud-cli) の文書からインストールと展開されたAzure CycleCloudサーバのFQDNの設定が必要です。

1. テンプレート本体をダウンロード
2. 展開、ディレクトリ移動
3. cyclecloudコマンドラインからテンプレートインストール 
   - tar zxvf cyclecloud-genomicswfe<version>.tar.gz
   - cd cyclecloud-genomicswfe<version>
   - cyclecloud project upload azure-storage
   - cyclecloud import_template -f templates/genomicswfe.txt
4. 削除したい場合、 cyclecloud delete_template genomicswfe コマンドで削除可能

***
Copyright Hiroshi Tanaka, hirtanak@gmail.com, @hirtanak All rights reserved.
Use of this source code is governed by MIT license that can be found in the LICENSE file.
