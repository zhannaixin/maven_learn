call_clear_task.sh
. /app/batch/shell/env_ccfs.sh
cd /app/batch/javalib
java batpub.CallStorageProc S08P1_DAY_CLEAN_TASK  /app/batch/log/s08/CallStorageProc.log 1  s08
java batpub.CallStorageProc s08p_addinquirycusttype /app/batch/log/s08/CallstorageProc.log 0 s08


call_clear_task.sh.20131108
. /app/batch/shell/env_ccfs.sh
cd /app/batch/javalib
java batpub.CallStorageProc S08P1_DAY_CLEAN_TASK  /app/batch/log/s08/CallStorageProc.log 1  s08

call_s08p1_cleardata.sh
. /app/batch/shell/env_ccfs.sh
cd /app/batch/javalib
java batpub.CallStorageProc S08P_DELETEIN  /app/batch/log/s08/s08p1_cleardata.log 1  s08


s08p1_clear_refues_data_01.sh
. /app/batch/shell/env_ccfs.sh
cd /app/batch/javalib
java batpub.CallStorageProc s08p1_clear_refues_data_01 /app/batch/log/s08/CallStorageProc.log 1  s08 

s08p1_clear_refues_data_02.sh
. /app/batch/shell/env_ccfs.sh
cd /app/batch/javalib
java batpub.CallStorageProc s08p1_clear_refues_data_02 /app/batch/log/s08/CallStorageProc.log 1  s08 

s08p1_clear_refues_data_03.sh
. /app/batch/shell/env_ccfs.sh
cd /app/batch/javalib
java batpub.CallStorageProc s08p1_clear_refues_data_03 /app/batch/log/s08/CallStorageProc.log 1  s08 

s08p1_clear_refues_data_04.sh
. /app/batch/shell/env_ccfs.sh
cd /app/batch/javalib
java batpub.CallStorageProc s08p1_clear_refues_data_04 /app/batch/log/s08/CallStorageProc.log 1  s08 

s08p_clear_refuse_pre.sh
. /app/batch/shell/env_ccfs.sh
cd /app/batch/javalib
java batpub.CallStorageProc s08p_clear_refuse_pre /app/batch/log/s08/CallStorageProc.log 1  s08 

s09p2_08_apinfo_clear.sh
. /app/batch/shell/env_ccfs.sh
cd /app/batch/javalib
java batpub.CallSPForAPSRPT s09p2_08_apinfo_clear /app/batch/log/s08/s09apinfoCLEAR.log 1  s09

s09p2_08_apprinfo_clear.sh
. /app/batch/shell/env_ccfs.sh
cd /app/batch/javalib
java batpub.CallSPForAPSRPT s09p2_08_apprinfo_clear /app/batch/log/s08/s09apprinfoCLEAR.log 1  s09

s09p2_08_refuse_clear.sh
. /app/batch/shell/env_ccfs.sh
cd /app/batch/javalib
java batpub.CallSPForAPSRPT s09p2_08_refuse_clear /app/batch/log/s08/s09refuseclear.log 1  s09

s09p2_08_svyinfo_clear.sh
. /app/batch/shell/env_ccfs.sh
cd /app/batch/javalib
java batpub.CallSPForAPSRPT s09p2_08_svyinfo_clear /app/batch/log/s08/S09SVYINFOCLEAR.log 1  s09

s09p2_08_workflowinfo_clear.sh
. /app/batch/shell/env_ccfs.sh
cd /app/batch/javalib
java batpub.CallSPForAPSRPT s09p2_08_workflowinfo_clear /app/batch/log/s08/s09workflowinfoCLEAR.log 1  s09
