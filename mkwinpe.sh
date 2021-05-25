#!/usr/bin/bash
# ====================================================================
# Extract installfiles from ISO (if required)
# Create WinPE from installfiles
#
# Jens Boettge <boettge@mpi-halle.mpg.de>	2021-05-25
# ====================================================================


do_checkreq() {
	# check some requirements:
	for BIN in 7z mkwinpeimg; do
		WHICH=$(which $BIN)
		[ -z "$WHICH" ] && echo "[*E*]   Required program not found: $BIN" && ERR=$(($ERR + 1))
	done
	[ $ERR -gt 0 ] && exit 1
}


process_ISO(){
	# ask for ISO image
	echo -e "Do you want to extract a given ISO image?\nEnter path to ISO or leave it empty to skip."
	read -e -r -p "ISO image: " -i "$DEFAULT_ISO"  ISO_IMAGE

	if [ -n "$ISO_IMAGE" ]; then
		echo "[*D*]   Selected ISO: $ISO_IMAGE"
		if [ ! -f "$ISO_IMAGE" -o ! -r "$ISO_IMAGE" ]; then
			echo -e "[*E*]   File does not exist, is not a regular file, or is not readable:\n\t\t$ISO_IMAGE"
			exit 10
		fi
		
		echo "[*D*]   check target directory: installfiles"
		TGT_DIR=$THISDIR/installfiles
		# echo "[*D*]   target directory: $TGT_DIR"
		[ ! -e "$TGT_DIR" ] && mkdir "$TGT_DIR"
		if [ ! -d "$TGT_DIR" -o ! -w "$TGT_DIR" ]; then
			echo -e "[*E*]   Target exists, but is not a directory or not writeable:\n\t\t$TGT_DIR"
			exit 11
		fi
		echo -n "[*D*]   ...is directory empty?"
		ANS=''
		SZ_OPTS=''
		CONT=$(find "$TGT_DIR" | wc -l)
		if [ $CONT -gt 1 ]; then
			echo " - NO"
			echo -e "\nThe 'installfiles' target directory is not empty. What should I do?"
			ANS=
			while [ -z $ANS ]; do
				read -N 1 -e -r -p "[D]elete, [O]verwrite, [B]ackup, S[kip], e[X]it: " ANS
				ANS=$(echo ${ANS:-0} | tr A-Z a-z | tr -c -d dobsx)
			done
			#[ -n "$ANS" ] && echo "Answer: $ANS"
				case $ANS in
				d)
					echo "[*I*]   Deleting old content of $TGT_DIR"
					rm -rf $TGT_DIR
					mkdir $TGT_DIR
					;;
				o)
					echo "[*I*]   Overwriting content of $TGT_DIR"
					SZ_OPTS='-aoa'
					;;
				b)
					TS=$(date +"%Y-%m-%d_%H%M%S")
					BAC_DIR=${TGT_DIR}.backup.$TS
					echo "[*I*]   Create backup of $BAC_DIR"
					mv $TGT_DIR $BAC_DIR
					mkdir $TGT_DIR
					;;
				s)
					echo "[*I*]   Skipping extraction. Use existing content of $TGT_DIR"
					;;	
				x)
					echo "Good bye..."
					exit 0
					;;
			esac
		else
			echo " - Yes"
		fi

		if [ "$ANS" != "s" ]; then
			echo "[*D*]   Extracting ISO image..."
			7z x ${SZ_OPTS} -o${TGT_DIR} $ISO_IMAGE
			opsi-setup --set-rights ${TGT_DIR}
		fi
	else
		echo "[*I*]   Skipping ISO image"
	fi
}


process_WinPE(){
	PE_DIR=$THISDIR/winpe
	CP_OPTS=''
		if [ -d "$PE_DIR" ]; then
		echo -n "[*D*]   Is the WinPE directory empty?"
		ANS=''
		CONT=$(find "$PE_DIR" | wc -l)
		if [ $CONT -gt 1 ]; then
			echo " - NO"
			echo -e "\nThe 'winpe' target directory is not empty. What should I do?"
			ANS=
			while [ -z $ANS ]; do
				read -N 1 -e -r -p "[D]elete, [O]verwrite, [B]ackup, e[X]it: " ANS
				ANS=$(echo ${ANS:-0} | tr A-Z a-z | tr -c -d dobx)
			done
			#[ -n "$ANS" ] && echo "Answer: $ANS"
				case $ANS in
				d)
					echo "[*I*]   Deleting old content of $PE_DIR"
					rm -rf $PE_DIR
					mkdir $PE_DIR
					;;
				o)
					echo "[*I*]   Overwriting content of $PE_DIR"
					CP_OPTS="-f"
					# can't overwrite boot.wim with mkwinpeimg, so I have to delete it:
					rm -f $PE_DIR/sources/boot.wim
					;;
				b)
					TS=$(date +"%Y-%m-%d_%H%M%S")
					BAC_DIR=${PE_DIR}.backup.$TS
					echo "[*I*]   Create backup of $BAC_DIR"
					mv $PE_DIR $BAC_DIR
					mkdir $PE_DIR
					;;
				x)
					echo "Good bye..."
					exit 0
					;;
			esac
		else
			echo " - Yes"
		fi
	fi

	if [ ! -d "$THISDIR/installfiles/boot" -o ! -r "$THISDIR/installfiles/boot" ]; then
		echo -e "[*E*]   'installfiles/boot' not found or not readable!"
		exit 20
	fi

	mkdir -p winpe/sources
	echo -e "[*D*]   Copying winpe files"
	cp ${CP_OPTS} -a installfiles/boot* installfiles/efi winpe/

	if [ ! -f "$THISDIR/installfiles/sources/boot.wim" -o ! -r "$THISDIR/installfiles/sources/boot.wim" ]; then
		echo -e "[*E*]   'installfiles/sources/boot.wim' not found or not readable!"
		exit 21
	fi
	mkdir -p winpe-overlay/Windows/System32
	printf "%s\r\n" "c:\opsi\startnet.cmd" > winpe-overlay/Windows/System32/startnet.cmd

	mkwinpeimg --windows-dir=installfiles --overlay=winpe-overlay --only-wim winpe/sources/boot.wim

	[ -d winpe-overlay ] && rm -rf winpe-overlay

	opsi-setup --set-rights ${PE_DIR}
}


THISDIR=$(dirname $0)
# echo `readlink -f $THISDIR`
ERR=0

if [ -n "$1" -a -e "$1" ]; then
	DEFAULT_ISO="$1"
else
	# DEFAULT_ISO="iso/SW_DVD9_Win_Pro_10_21H1_64BIT_English_Pro_Ent_EDU_N_MLF_X22-55036.ISO"
	DEFAULT_ISO=""
fi

do_checkreq

process_ISO

process_WinPE
