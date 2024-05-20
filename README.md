# README.md

## Introduction

This project illustrates how to use a Python script to handle automatic restarts using SLURM's job scheduling system. The script can save its state and resume from where it left off if it is interrupted, whether manually or by SLURM's time limit.

## Prerequisites

- Python environment with the `dill` package installed (`pip install dill`).

## Files

- `main.py`: The main Python script that performs the task and handles interruptions.
- `restart.sh`: The SLURM job script that manages job submissions and restarts.

## Running the Example

### Using Python Script with Manual Interruptions

1. **Run the script**:
    ```bash
    python main.py
    ```
    The code above will print the `run_id` in the file RESTART.

2. **Interrupt the script**: Manually interrupt the script using `CTRL+C`. This triggers the signal handler, saves the session state, and exits the script.

3. **Resume the script**: Run the script again to resume from the last saved state, passing the run_id that is saved in `RESTART` file.
    ```bash
    python main.py
    ```

### Using Bash Script for Automatic Restart

1. **Prepare the restart script**: Ensure the `restart.sh` file is correctly set up.

2. **Run the script with bash**:
    ```bash
    bash restart.sh
    ```

3. **Monitor the restarts**: Each time `CTRL+C` is pressed, the script will save the state and restart until `MAX_RESTARTS` is reached. If you run the code unmodified, the value set for `MAX_RESTARTS` is 4.

### Using SBATCH Command for SLURM

To use SLURM's `sbatch` command and handle automatic restarts when the session runs out, follow these steps:

1. **Modify the Signal Handling in `main.py`**:
    Update the signal handler in `main.py` to use `SIGURG` (signal number 23), which is more appropriate for SLURM notifications.
    ```python
    signal.signal(signal.SIGURG, signal_handler)
    ```

2. **Modify the SLURM Job Script (`restart.sh`)** by changing line 55 from `bash <restart.sh` to `sbatch <restart.sh`. To better understand how this works, check out section 15.4 of [Batch schedulers: Bringing order to chaos](https://learning.oreilly.com/library/view/parallel-and-high/9781617296468/OEBPS/Text/ch15_Robey.htm#sigil_toc_id_306) (MBZUAI students need to use their university email to access this website) and read the [slurm documentation](https://slurm.schedmd.com/sbatch.html).
4. **Monitor the job**:
    - SLURM will handle the execution and restart of the job as needed.
    - The job script will write outputs to `run.out` and manage session states using the `RESTART` and `DONE` files.

## Conclusion

This example demonstrates how to set up a Python script with SLURM to handle automatic restarts. By saving the script's state using `dill` and utilizing SLURM's job management features, you can ensure long-running tasks continue smoothly across interruptions.