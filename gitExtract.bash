#!/bin/bash
#-----------------------------------------------------------------------------+
# gitExtract.bash -> Retrieve one file for one given tag                      |
#---------+------------+------------+-----------------------------------------+
#  V00.00 + Ph. Giroux + 2019/12/31 + Creation                                |
#  V00.01 + Ph. Giroux + 2020/01/06 + Re-evaluate path after checkout tag     |
#  Limits
#    * Constant URL is hard-coded
#    * Must be used at the root directory of a git repo
#    * No help in this V00.00 draft
#    * Only modified files are discarded in order to have a clean copy of repo
#    * /tmp directory must exist, there is no alternative directory proposed
#    * No multiple occurences of files are managed
#    * Accented characters make program fail !
#    Use :     gitExtract.bash <Tag> <File>
#    Example : gitExtract.bash FotH_20170101.0 DIMANCHE.pdf
#    This
#       - checks git available, tag exists, file exists
#       - copy local repo in /tmp dir and discards modified files
#       - checkouts repo on the specified tag and copy specified file
#    Result will be in : /tmp/gitExtract-$$
#---------+------------+------------+-----------------------------------------+

# Constant : Modify according to your configuration
# -------------------------------------------------
Url=ssh://philippe@192.168.1.3/home/philippe

# Get params
# ----------
Tag=$1
File=$2

# Check dir is git repo
# ---------------------
CheckGit=$(ls -d .git)
if [[ "[${CheckGit}]" != "[.git]" ]]
then 
	echo "Trap #1 : Current dir isn't git repo"
	exit 1
else
	echo "Check #1 : Current dir is git repo"
fi

# Check file does exist
# 2Bdone : check if exists more than one time
# -------------------------------------------
Path=$(find . -name "${File}")
CheckPath=$(ls "${Path}")
if [[ "[${CheckPath}]" == "[]" ]]
then
	echo "Trap #2 : file ${File} not found"
	exit 2
else
	echo "Check #2 : file ${File} path is ${Path}"
fi

# Check tag does exist
# --------------------
CheckTag=$(git tag --list | grep "${Tag}")
if [[ "${CheckTag}" != "${Tag}" ]]
then 
	echo "Trap #3 : tag ${Tag} not found"
	exit 3
else
	echo "Check #3 : tag ${Tag} does exist"
fi

# Check tmp dir does exist
# ------------------------
CheckTmp=$(ls -d /tmp)
if [[ "[${CheckTmp}]" == "[]" ]]
then 
	echo "Trap #4 : /tmp dir not found"
	exit 4
else
	echo "Check #4 : /tmp dir does exist"
fi

# Check tmp is writable -> make result dir
# ----------------------------------------
WorkingDir="/tmp/gitExtract-$$"
CheckMkDir=$(mkdir $WorkingDir 2>&1)
if [[ "[${CheckMkDir}]" != "[]" ]]
then 
	echo "Trap #5 : could not create working dir"
	echo "Error msg is : ${CheckMkDir}"
	exit 5
else
	echo "Check #5 : working dir is created -> ${WorkingDir}"
fi

# cp git repo in tmp
# ------------------
CurrentDir=$(pwd)
GitRepo=$(pwd | awk -F\/ '{print $NF}')
cd /tmp
echo "Copy git repo in /tmp dir... wait for a few minutes please"
cp -r ${CurrentDir} ${GitRepo}

# Suppress all not commited files
# -------------------------------
cd ${GitRepo}
git status -s | grep "^ M" | sed "s/^ M//" | awk '{print "git checkout " $0}' > ${WorkingDir}/gitCoModiFiles-$$.bash
chmod 755 ${WorkingDir}/gitCoModiFiles-$$.bash
${WorkingDir}/gitCoModiFiles-$$.bash
#git status -s | grep "^??" | sed "s/^??//" | awk '{print "rm -rfd " $0}' > ${WorkingDir}/gitRmUntracked-$$.bash
#chmod 755 ${WorkingDir}/gitRmUntracked-$$.bash
#${WorkingDir}/gitRmUntracked-$$.bash

# Select asked tag
git checkout -q ${Tag}

# Check file does exist (path may have changed)
# -------------------------------------------
CheckPath=$(ls "${Path}")
if [[ "[${CheckPath}]" == "[]" ]]
then
	echo "Trap #6 : file ${File} not found ; try to find it again"
	Path=$(find . -name "${File}")
	CheckPath=$(ls "${Path}")
	if [[ "[${CheckPath}]" == "[]" ]]
	then
		echo "Trap #6 : file ${File} definitely not found"
		exit 6
	else
		echo "Check #6 : file ${File} path was ${Path} at the time"
	fi
else
	echo "Check #6 : file ${File} path is ${Path}"
fi


# Copy asked file in Working Dir
# ------------------------------
cp ${Path} ${WorkingDir}
echo "Your file is available at ${WorkingDir}/${File}"
cd ${CurrentDir}

# Sweeping temporary repo
# -----------------------
echo "Sweeping tempo repo"
rm -rfd /tmp/${GitRepo}

