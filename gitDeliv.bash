#!/bin/bash
#-----------------------------------------------------------------------------+
# gitDeliv.bash -> git status / delivery note / add / commit / tag            |
#---------+------------+------------+-----------------------------------------+
#  V00.00 + Ph. Giroux + 2020/01/24 + Creation                                |
#---------+------------+------------+-----------------------------------------+
#  Limits
#    * Must be used at the root directory of a git repo
#    * Only added & modified files are managed (not removed)
#    * No help in this V00.00 draft
#    Use :     gitDeliv.bash <Tag>
#    Example : gitDeliv.bash FotH_20200126.0
#    This
#       - checks git available, tag does not exist yet
#       - pre-fills Delivery File with added / modified files
#       - opens Delivery File in order to
#              * discard files not to deliver
#              * fill Comment line
#       - gets Comment line & files to be delivered
#       - adds files to be delivered
#       - commits delivery with Comment line
#       - tags delivery with given parameter and same Comment line
#---------+------------+------------+-----------------------------------------+

# Get params
# ----------
Tag=$1

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

# Check tag does not exist yet
# 2Bdone : automatically increment last digit
# -------------------------------------------
CheckTag=$(git tag --list | grep "${Tag}")
if [[ "${CheckTag}" == "${Tag}" ]]
then 
	echo "Trap #2 : tag ${Tag} already exists"
	exit 2
else
	echo "Check #2 : tag ${Tag} does not exist yet"
fi

# Check tmp dir does exist
# ------------------------
CheckTmp=$(ls -d /tmp)
if [[ "[${CheckTmp}]" == "[]" ]]
then 
	echo "Trap #3 : /tmp dir not found"
	exit 3
else
	echo "Check #3 : /tmp dir does exist"
fi

# Check tmp is writable -> touch deliv file
# -----------------------------------------
DelivFile="/tmp/GitDelivFile-$$.txt"
CheckTouchDelivFile=$(touch /tmp/GitDelivNote-$$.txt 2>&1)
if [[ "[${CheckTouchDelivFile}]" != "[]" ]]
then 
	echo "Trap #4 : could not create delivery file"
	echo "Error msg is : ${CheckTouchDelivFile}"
	exit 4
else
	echo "Check #4 : deliv file is created -> ${DelivFile}"
fi

# Get git short status & redirect in deliv file
# ---------------------------------------------
git status -s > ${DelivFile}

# Add comment line in deliv file
# ------------------------------
echo "Comment : " >> ${DelivFile}

# Open deliv file in order to select elements to deliver & write comment
# ----------------------------------------------------------------------
gedit ${DelivFile}

# 2BDone : check list of elements to deliver (may be accidentally modified)
#          check comment is not empty
# -------------------------------------------------------------------------

# Lines beginning with " M " represent modified elements
# ------------------------------------------------------
ListModified=$(grep "^ M " ${DelivFile} | sed "s/^ M //")
echo " ----- "
echo "Modified files are :"
echo ${ListModified}

# Lines beginning with "?? " represent new elements
# -------------------------------------------------
ListNew=$(grep "^?? " ${DelivFile} | sed "s/^?? //")
echo " ----- "
echo "New files are :"
echo ${ListNew}

# Concatenate modified elements list & added elements list
# --------------------------------------------------------
List2Deliv="${ListModified} ${ListNew}"
echo " ----- "
echo "Files to deliver are :"
echo ${List2Deliv}

# Line beginning with "Comment : " represents comment
# 2BDone : check it's not empty
# ---------------------------------------------------
Comment=$(grep "Comment : " ${DelivFile} | sed "s/Comment : //")
#Comment=\"${Comment}\"
echo " ----- "
echo "Comment is : ${Comment}"

echo "Process (Y/N) ?"
read Process

if [[ ${Process} != "Y" ]]
then
	echo "Ok, see you soon !"
	exit 0
else
	echo "Ok, let's go !"
fi

git add ${List2Deliv}
git commit -m "${Comment}"
git tag -m "${Comment}" ${Tag}

# Sweeping deliv file
# -------------------
echo "Sweeping deliv file"
echo "rm -f ${DelivFile}"
#rm -f ${DelivFile}

