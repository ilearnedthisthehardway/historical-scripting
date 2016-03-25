#!/bin/bash
# Test SSH connection to given host with given user and walk them through populating key if neccessary.

ssh_helper() {
  testhost=$1;
  # first, attempt to ssh a simple command to the host
  $(which ssh) -q -n -o NumberOfPasswordPrompts=0 $testhost id > /dev/null;
  status=$?;
  if [ $status -eq 0 ]; then	# ssh would have returned 0 if successful
    return 0;
  else
    echo "::Need to send $testhost public key...";
    # look for key file (generally identity.pub in ~/.ssh/ directory
    pubkey=`find ~ -maxdepth 2 -name "id*.pub" | tail -n1`;	# a user might have more then 1 public key, but we just need one, any one
    while [ -z $pubkey ]; do 	#pubkey is empty = no pubkey
      echo "::but first one needs to be generated...";
      if [ ! -d ~/.ssh/old_ids/ ]; then mkdir ~/.ssh/old_ids/; fi
      mv -f ~/.ssh/id* ~/.ssh/old_ids/ >& /dev/null
      xterm -title "key maker" -e "echo '===---TAKE DEFAULTS TO ALL QUESTIONS...HIT ENTER A FEW TIMES'; ssh-keygen -t dsa;";
      pubkey=`find ~ -maxdepth 2 -name "id*.pub" | tail -n1`;	# a user might have more then 1 public key, but we just need one, any one
    done
    echo "===---You need to enter your password on $testhost this one last time:";
    cat $pubkey | $(which ssh) $testhost "umask 077; test -d .ssh || mkdir .ssh ; cat >> .ssh/authorized_keys" || exit 1;
    echo "::And now you should be able to ssh to $testhost without having to enter a password.";
  fi
} ###> end of ssh_helper

ssh_helper $@;

exit 0;