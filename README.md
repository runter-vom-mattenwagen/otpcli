# OTPCLI - 2FA in Bash

OTPCLI is a Bash script around oathtool which calculates 2FA-codes from keyfiles. It uses GPG if wanted.

## Setup/PreReqs

### oathtool

Program that does the actual work. Install it with ```$ apt install oathtool``` on deb based systems or ```$ yum install oathtool``` on rpm based.

### GPG

The keyfiles can be encrypted with GPG. GPG itself should be already installed on your system. If you have already configured an identity, you're ready to go.

### get it to work

When you create a 2nd factor on any service in order to use it later e.g. with Google Authenticator, the QR code presented to you actually contains a security key. The 2FA app then uses this key in combination with the current time to calculate your one-time password. 

Create a directory ```.otpkeys``` in your homedir with ```$ mkdir ~/.otpkeys``` or your desired way to create directories and then create a keyfile in this directory for each service in the format ```<SERVICENAME>.key```, in which you write the relevant security key.

OTPCLI can handle GPG encrypted keyfiles. Provided you have already a GPG identity configured, then simply encrypt the keyfiles with ```gpg -e -r "<IDENTITY>" <SERVICE>.key``` and delete the not encrypted file.

Finally copy otp.sh to a place from where you want to start it.

## Usage

Easiest way is simply type ```otp.sh``` and select a service from the list. The second easiest method is to type ```otp.sh <SERVICENAME>```, without the suffix key oder key.gpg. Both options answer with the one-time password which you should copy in time into the appropriate field.

The command line options "-n" and "-e" are currently sort of dummy. :-)

<img src="https://runter-vom-mattenwagen.github.io/otpcli.gif">


