# assemble a PATH to all installed executables
EXTRA_PATH=`find ~/opt/formal/ -type f -executable -print | xargs -L1 dirname | sort | uniq | tr '\012' ':' | head -c -1`

echo "Adding $EXTRA_PATH to $$PATH".

#export PATH=$PATH:$EXTRA_PATH
