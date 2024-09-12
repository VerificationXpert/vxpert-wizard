#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to check version of a command
get_version() {
    if command_exists "$1"; then
        "$1" --version | head -n 1
    else
        echo "$1 is not installed"
    fi
}

# Display current installed software versions
echo "Checking current installed software versions..."

# Python, clang, g++, iverilog, verilator
PYTHON_VERSION=$(get_version "python3")
CLANG_VERSION=$(get_version "clang")
GPP_VERSION=$(get_version "g++")
IVERILOG_VERSION=$(get_version "iverilog")
VERILATOR_VERSION=$(get_version "verilator")

# Display current versions
echo "Current versions on system:"
echo "Python 3: $PYTHON_VERSION"
echo "Clang: $CLANG_VERSION"
echo "G++: $GPP_VERSION"
echo "Icarus Verilog: $IVERILOG_VERSION"
echo "Verilator: $VERILATOR_VERSION"
echo ""
echo "Proceeding with installations/updates..."

# Update system packages
sudo apt update
sudo apt upgrade -y

# Install Python 3 and virtual environment tools if not installed
if ! command_exists "python3"; then
    echo "Installing Python 3 and pip..."
    sudo apt install -y python3 python3-venv python3-pip help2man
else
    echo "Python 3 is already installed: $PYTHON_VERSION"
fi

# Create a virtual environment in the home directory if it doesn't exist
if [ ! -d "$HOME/vxpert-venv" ]; then
    echo "Creating Python virtual environment in $HOME/vxpert-venv..."
    python3 -m venv $HOME/vxpert-venv
fi

# Activate the virtual environment
echo "Activating Python virtual environment..."
source $HOME/vxpert-venv/bin/activate

# Install Python dependencies from requirements.txt (always install/update these)
echo "Installing/updating Python packages in virtual environment..."
pip install --upgrade -r $HOME/vxpert-repo/requirements.txt

# Install Clang, G++, Icarus Verilog, and development tools if not installed
if ! command_exists "clang"; then
    echo "Installing Clang..."
    sudo apt install -y clang
else
    echo "Clang is already installed: $CLANG_VERSION"
fi

if ! command_exists "g++"; then
    echo "Installing G++..."
    sudo apt install -y g++
else
    echo "G++ is already installed: $GPP_VERSION"
fi

if ! command_exists "iverilog"; then
    echo "Installing Icarus Verilog..."
    sudo apt install -y iverilog
else
    echo "Icarus Verilog is already installed: $IVERILOG_VERSION"
fi

# Install Verilator (specific version)
if ! command_exists "verilator"; then
    echo "Installing Verilator version v5.028..."
    git clone https://github.com/verilator/verilator.git $HOME/verilator
    cd $HOME/verilator
    git checkout v5.028
    autoconf
    ./configure CC=clang CXX=clang++
    make -j$(nproc) 
    sudo make install
    cd $HOME
else
    echo "Verilator is already installed: $VERILATOR_VERSION"
fi


# Display summary table
echo ""
echo "---------------------------------------------------------"
echo "                    Installation Summary"
echo "---------------------------------------------------------"
printf "%-20s %-20s\n" "Software" "Version"
printf "%-20s %-20s\n" "Python 3" "$(get_version 'python3')"
printf "%-20s %-20s\n" "Clang" "$(get_version 'clang')"
printf "%-20s %-20s\n" "G++" "$(get_version 'g++')"
printf "%-20s %-20s\n" "Icarus Verilog" "$(get_version 'iverilog')"
printf "%-20s %-20s\n" "Verilator" "$(get_version 'verilator')"
echo "---------------------------------------------------------"
echo ""

# Deactivate virtual environment
deactivate

# Final message
echo "Installation and updates completed!"

