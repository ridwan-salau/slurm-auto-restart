import dill
from time import sleep
from pathlib import Path
import argparse
import uuid

import signal
import sys

parser = argparse.ArgumentParser("test-restart")
parser.add_argument("--run-id", type=str, help="A unique run ID", default=uuid.uuid4().hex)

args = parser.parse_args()

signal_received = False
def signal_handler(signal_number, frame):
    global signal_received
    signal_received = True
    print(f"Received signal: {signal_number}. Waiting for iteration to complete...")

# Register the signal handler for the specific signal number
# I use SIGINT for this illustration as it is the signal that gets raised when you perform keybord interrupt with "CTRL+C"
# The signal number for SIGINT is 2. 
signal.signal(signal.SIGINT, signal_handler)

start = 0

if Path(f"./{args.run_id}.pkl").exists():
    dill.load_session(f"./{args.run_id}.pkl")
    Path(f"./{args.run_id}.pkl").unlink()

for i in range(start, 100):



    # Your training step
    print(f"Running {i}-th iteration...")
    sleep(2)


    # The variable "signal_received" is a global variable that gets altered when SIGINT is received.
    if signal_received:
        signal_received = False
        start = i + 1
        print(f"Dumping session to file {args.run_id}.pkl ...")
        print(f"Resume the run using `python main.py --run-id {args.run_id}`")
        
        # You need to write to RESTART file to inform the shell script.
        # In this example, I will write a unique run_id which I want to preserve across
        # runs and use as the file name for the session to be saved and restored
        with open("RESTART", "w") as f: f.write(args.run_id)
        dill.dump_session(f"./{args.run_id}.pkl")
        sys.exit(0)

# You need to write to DONE file to inform the shell script
with open("DONE", "w") as f: f.write("")
