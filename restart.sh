#!/bin/sh
#
# Use this script by submitting with the bsubmit command "sbatch < restart.sh".
#
# Change the environment variables for each problem. The rest of the file should
# not need to be changed. Keep a watch out for runaway behaviors --
# the downside of an automated system.
#
# This script relies heavily on two files, RESTART and DONE, written
# out to the run directory. The application needs to write out a file
# called RESTART if it exits due to a run-time limit.
#
#SBATCH -N 1
#SBATCH -n 4
#SBATCH --signal=23@160
#SBATCH -t 00:08:00

# Do not place bash commands before the last SBATCH directive
# Behavior can be unreliable

NUM_CPUS=${SLURM_NTASKS}
OUTPUT_FILE=run.out
EXEC_NAME=./main.py
MAX_RESTARTS=4

if [ -z ${COUNT} ]; then
   export COUNT=0
fi

((COUNT++))
echo "Restart COUNT is ${COUNT}"

if [ ! -e DONE ]; then
   if [ -e RESTART ]; then
      echo "=== Restarting ${EXEC_NAME} ==="             >> ${OUTPUT_FILE}
      run_id="--run-id `cat RESTART`"
      rm -f RESTART
   else
      echo "=== Starting problem ==="                    >> ${OUTPUT_FILE}
      run_id=""
   fi

   # Entrypoint command here
   srun python main.py $run_id                                &>> ${OUTPUT_FILE}
   STATUS=$?

   if [ ${COUNT} -ge ${MAX_RESTARTS} ]; then
      echo "=== Reached maximum number of restarts ==="  >> ${OUTPUT_FILE}
      date > DONE
   fi

   if [ ${STATUS} = "0" -a ! -e DONE ]; then
      echo "=== Submitting restart script ==="           >> ${OUTPUT_FILE}
      bash <restart.sh
   fi
fi