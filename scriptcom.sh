#!/bin/bash
#Program generets pair of public and private keys based on the points multiplier algorithm on the elliptic curve
#compatible with Secp256k1 standard. It uses SHA-2-256 algorithm for further user interaction support

#predefined constants
    #p=2^256-2^32-2^9-2^8-2^7-2^6-2^4-1
    #p=FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFE FFFFFC2F
    #p=115792089237316195423570985008687907853269984665640564039457584007908834671663
    p=FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F

    #G=04 79BE667E F9DCBBAC 55A06295 CE870B07 029BFCDB 2DCE28D9 59F2815B 16F81798 483ADA77 26A3C465 5DA4FBFC 0E1108A8 FD17B448 A6855419 9C47D08F FB10D4B8
    GX=79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798
    GY=483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8

    #GARG=FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFE BAAEDCE6 AF48A03B BFD25E8C D0364141
    GARG=FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141

#functions answers
    SUMANS=""
    SUBANS="" 
    MULANS="" 
    DIVANS="" 
    DIVINTANS=""
    POWANS=""
    MODANS=""
    CONANS=""
    REVANS=""

    PNTSUMANSX=""
    PNTSUMANSY=""

    PLAANS=""

    CSRNGANS=""
    VALIDATEANS=""

#numeric functions
Sum() {

temp="sum"
SUMANS=`python arithmetic.py $temp $1 $2`

}
Sub() {

temp="sub"
SUBANS=`python arithmetic.py $temp $1 $2`

}
Mul() {

temp="mul"
MULANS=`python arithmetic.py $temp $1 $2`

}
Div() {

temp="div"
DIVANS=`python arithmetic.py $temp $1 $2`

}
DivInt() {

temp="fdiv"
DIVINTANS=`python arithmetic.py $temp $1 $2`

}
Pow() {

temp="pow"
POWANS=`python arithmetic.py $temp $1 $2`

}
Mod() {

temp="mod"
MODANS=`python arithmetic.py $temp $1 $2`

}
Con() {

temp="con"
CONANS=`python arithmetic.py $temp $1 $2`

}
Rev() {

REVANS=`python modular.py $1 $p`

}

PntSum() {

ax=$1
ay=$2

bx=$3
by=$4

A="$ax$ay"
B="$bx$by"


if [[ $A == $B ]]; then

    Mul $ax $ax

    Mul $MULANS "3"

    temp1=$MULANS

    Mul $ay "2"

    Mod $MULANS $p

    Rev $MODANS

    Mul $temp1 $REVANS

    Mod $MULANS $p

    c=$MODANS

else

    Sub $by $ay

    temp1=$SUBANS
    
    Sub $bx $ax

    Mod $SUBANS $p

    Rev $MODANS

    Mul $temp1 $REVANS

    Mod $MULANS $p

    c=$MODANS

fi

Mul $c $c

Sub $MULANS $ax

Sub $SUBANS $bx

Mod $SUBANS $p

rx=$MODANS


Sub $ax $rx

Mul $c $SUBANS

Sub $MULANS $ay

Mod $SUBANS $p

ry=$MODANS


PNTSUMANSX=$rx
PNTSUMANSY=$ry

}

PLA() {

PLAANS=`python logic.py $1 $2 $3`

}

TwoMul() {

TWOMULANS=`python binarypows.py $1`

}

#generation-related functions
CSRNG() {

CSRNGANS=`od -A n -t x -N 32 /dev/urandom | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]'`

}
SHA() {

SHAANS=`python sha2.py $1`

}

Validate() {

M=$1

M=`echo $M | tr '[:lower:]' '[:upper:]'`

n=$(( 1,158*(10**77) - 1 ))

MD=`echo "ibase=16;$M" | bc`

MD=`echo $MD | sed 's=\\\ ==g'`

if [[ $MD -lt n ]]; then

    VALIDATEANS="TRUE"

else

    VALIDATEANS="FALSE"

fi

}

#main#

#Taking user's input

VERBOSE="FALSE"
ORGSEED=""

while getopts ":hvps:" opt; do

  case ${opt} in
    h)
      echo "Program generates a private-public keys pair."
      echo "Genereting process uses ECDSA algorithm compatible with"
      echo "Secp256k1 international standard."
      echo "Result is stored in ecrypted file called 'keys'."
      echo "Usage: zscript.sh [OPTIONS]"
      echo "Options list:"
      echo "-h displays help"
      echo "-v displays version"
      echo "-p (public) keys would be generated overt"
      echo "-s takes seed from user's input, default is generated randomly"
      exit 1
      ;;
    v)
      echo "Author: Daniel Szynszecki s175683"
      echo "Program generates a private-public keys pair"
      echo "Version: v_1.1"
      exit 1
      ;;
    p)
      VERBOSE="TRUE"
      ;;
    s)
      ORGSEED=$OPTARG
      ;;
    \?)
      echo "Invalid option: $OPTARG" 1>&2
      ;;
    :)
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      ;;
  esac

done
shift $((OPTIND -1)) #remove handled options from $@

if [[ $VERBOSE == "FALSE" ]]; then

    read -s -p "Enter password: " PASSWORD

else

    read -p "Enter password: " PASSWORD

fi

Xp=0
Yp=0

echo
echo
echo "Generating in progress... please wait."
echo

while : ; do


#Generating private key

    while : ; do

        if [[ -z $ORGSEED ]]; then

            CSRNG
            SEED=$CSRNGANS

        else

            SHA $ORGSEED
            SEED=$SHAANS

        fi

        Validate $SEED

        [[ $VALIDATEANS == "TRUE" ]] || break

    done

    KEY_PRIVATE=$SEED

    
#Generating public key

    i=1
    currentx=$GX
    currenty=$GY

    PLA "<=" $i $KEY_PRIVATE
    condition=$PLAANS

    while [[ $condition == "1" ]] ; do

        Con $KEY_PRIVATE $i

        if [[ $CONANS == $i ]]; then

            if [[ $Xp == 0 ]]; then

                Xp=$currentx
                Yp=$currenty

            else

                PntSum $Xp $Yp $currentx $currenty
                Xp=$PNTSUMANSX
                Yp=$PNTSUMANSY

            fi

        fi

        PntSum $currentx $currenty $currentx $currenty
        currentx=$PNTSUMANSX
        currenty=$PNTSUMANSY

        TwoMul $i
        i=$TWOMULANS

        PLA "<=" $i $KEY_PRIVATE
        condition=$PLAANS

    done

    echo
    echo "done!"

    PLA "!=" '0' $Xp
    con1=$PLAANS
    PLA "!=" '0' $Yp
    con2=$PLAANS

    if [[ $con1 == 1 && $con2 == 1 ]]; then

        break

    fi

done

KEY_PUBLIC="$Xp$Yp"

if [[ $VERBOSE == "TRUE" ]]; then

    echo $ORGSEED
    echo $KEY_PRIVATE
    echo $KEY_PUBLIC

fi

TEMPFILE=`mktemp`
trap "rm -rf $TEMPFILE" EXIT

echo -e "$KEY_PRIVATE\n$KEY_PUBLIC" > $TEMPFILE

echo $PASSWORD | gpg --batch --no-tty --yes --passphrase-fd 0 --symmetric -o keys.gpg $TEMPFILE
