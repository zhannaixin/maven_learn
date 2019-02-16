. /app/batch/shell/env_ccfs.sh
cd /app/batch/javalib

  i=0
  while [ $i -le 1 ]; 
  do
         a=$(date +%H%M)
     if [ $a -ge 2048 ]; then
         return
                  fi
                java batpub.CallStorageProc S08P_INBOXTASK /app/batch/log/s08/CallStorageProc.log 1 s08
                sleep 30
  done