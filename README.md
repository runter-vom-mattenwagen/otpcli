# OTPCLI - 2FA in Bash

OTPCLI is a Bash script around oathtool which calculates 2FA-codes from keyfiles. It uses GPG if desired.

## Setup/PreReqs

### oathtool

Program that does the actual work. Install it with ```$ apt install oathtool``` on deb based systems or ```$ yum install oathtool``` on rpm based.

### GPG

The keyfiles can be encrypted with GPG. GPG itself should be already installed on your system. If you have already configured an identity, you're ready to go.

### get it to work

When you create a 2nd factor on any service in order to use it later e.g. with Google Authenticator, the QR code presented to you actually contains a security key. The 2FA app then uses this key in combination with the current time to calculate your one-time password. 

The script expect a directory ```.otpkeys``` in your homedir to store service information and the name of the GPG identity. Both will be created automatically on first run if not present. For each service a file ```<SERVICENAME>.key``` will be created which contains its security key. If the key is encrypted with GPG the file will get the extension ```.gpg```.

OTPCLI can encrypt the keyfiles with ```gpg -e -r "<IDENTITY>" <SERVICE>.key```. The unencrypted file will automatically be deleted.

tl;dr:

- install oathtool
- have a working GPG configuration (optional)
- copy otp.sh to a directory in path
- run otp.sh


## Usage

Easiest way is simply type ```otp.sh``` and select a service from the list. The second easiest method is to type ```otp.sh <SERVICENAME>```, without the suffix .key or .key.gpg. Both options answer with the one-time password which you should copy in time into the appropriate field.

<img src="https://runter-vom-mattenwagen.github.io/otpcli.gif">

## Autocompletion

Copy otp_complete to /etc/bash_completion.d/


