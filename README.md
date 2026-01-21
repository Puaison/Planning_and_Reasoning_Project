# Planning and Reasoning Project

This repository contains PDDL domains and problems developed for a planning and reasoning project.
The project supports different planners, with a more complete modeling designed to run with **ENHSP**.

---

## Requirements

- **Operating System**: Linux (tested on Ubuntu 24.04 LTS)
- **Java**: OpenJDK (version 11 or newer recommended)

Check Java installation:
```bash
java -version
```

If Java is not installed:
```bash
sudo apt update
sudo apt install openjdk-17-jdk
```

---

## Installing ENHSP

ENHSP is required to run the advanced versions of the PDDL domains.

### Step 1: Clone ENHSP
```bash
git clone https://gitlab.com/enricos83/ENHSP-Public.git
```

### Step 2: Enter the ENHSP directory
```bash
cd ENHSP-Public
```

### Step 3: Compile ENHSP
```bash
./compile
```

After compilation, the file `enhsp.jar` will be available inside the `enhsp-dist` directory.

---

## Making ENHSP Executable from Anywhere

To run ENHSP from any directory, create a system-wide command.

### Step 4: Get the absolute path to `enhsp.jar`

Example:
```text
/home/your_username/ENHSP-Public/enhsp-dist/enhsp.jar
```

---

### Step 5: Create a wrapper script
Open a new terminal and run:
```bash
sudo nano /usr/local/bin/enhsp
```

### Step 6: Add the following content
```bash
#!/bin/bash
java -jar /path/to/enhsp.jar "$@"
```

Replace `/path/to/enhsp.jar` with the actual absolute path.

---

### Step 7: Make the script executable
```bash
sudo chmod +x /usr/local/bin/enhsp
```

You can now run ENHSP from any directory using the `enhsp` command.

---

## Installing This Project

Choose a directory where you want to clone this repository.

### Step 8: Clone the repository
```bash
git clone <REPOSITORY_LINK>
```

Replace `<REPOSITORY_LINK>` with the actual GitHub URL.

---

### Step 9: Enter the PDDL directory
```bash
cd Planning_and_Reasoning_Project/PDDL
```

---

## Running the Planner

### Step 10: Run ENHSP on the PDDL files
```bash
enhsp -o domain_2_rico.pddl -f problem_2_3_rico.pddl -planner opt-hmax
```

---

## Notes on PDDL Domains and Planners

### Fast Downward Domains

- `domain_1_rico.pddl`
- `problem_1_x_rico.pddl`

These files:
- Can be run **only with Fast Downward**
- Represent a **simpler modeling** of the problem
- Support **A\*** search with both **hmax** and **hadd** heuristics

---

### ENHSP Domains

- `domain_2_rico.pddl`
- `domain_3_rico.pddl`

These domains:
- Are designed to run with **ENHSP**
- Represent a **more complete model**
- Extensions include:
  - Energy constraints for robots
  - Multiple goal positions to be achieved sequentially

---

## Heuristics and Search Strategies in ENHSP

Default heuristic:
```bash
-planner opt-hmax
```

To use **hadd**:
```bash
-planner sat-hadd
```

### Important Notes

- ENHSP supports **A\*** search only with **hmax**
- **hadd** is supported only with **Greedy Best-First Search**
- Using `sat-hadd`:
  - Produces **sub-optimal plans**
  - Requires **significantly more computation time**

In contrast, **Fast Downward** supports **A\*** with both **hmax** and **hadd** in the simpler domain version.
