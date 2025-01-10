#!/bin/bash

RESULTS_DIR="buffer_size_tests"
LOG_FILE="$RESULTS_DIR/test_summary.log"
mkdir -p $RESULTS_DIR

# Header with ASCII art
echo "________▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▄______________________________________________________________"
echo "_______█░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░█_____________________________________________________________"
echo "_______█░▒▒▒▒▒▒▒▒▒▒▄▀▀▄▒▒▒░░█▄▀▀▄_________________________________________________________"
echo "__▄▄___█░▒▒▒▒▒▒▒▒▒▒█▓▓▓▀▄▄▄▄▀▓▓▓█_________________________________________________________"
echo "█▓▓█▄▄█░▒▒▒▒▒▒▒▒▒▄▀▓▓▓▓▓▓▓▓▓▓▓▓▀▄_________________________________________________________"
echo "_▀▄▄▓▓█░▒▒▒▒▒▒▒▒▒█▓▓▓▄█▓▓▓▄▓▄█▓▓█_________________________________________________________"
echo "_____▀▀█░▒▒▒▒▒▒▒▒▒█▓▒▒▓▄▓▓▄▓▓▄▓▒▒█________________________________________________________"
echo "______▄█░░▒▒▒▒▒▒▒▒▒▀▄▓▓▀▀▀▀▀▀▀▓▄▀_________________________________________________________"
echo "____▄▀▓▀█▄▄▄▄▄▄▄▄▄▄▄▄██████▀█▀▀___________________________________________________________"
echo "____█▄▄▀_█▄▄▀_______█▄▄▀_▀▄▄█_____________________________________________________________"

echo "Starting tests at $(date)" | tee "$LOG_FILE"

GREEN="\033[0;32m"
RED="\033[0;31m"
PURPLE="\033[0;35m"
RESET="\033[0m"

echo -e "${PURPLE}==========================================================================${RESET}"
echo "Running Mandatory Tests! Good luck, Wizard!"
echo -e "${PURPLE}==========================================================================${RESET}"

BUFFER_SIZES=(1 2 4 8 16 32 64 128 256 512 1024)

for BUFFER_SIZE in "${BUFFER_SIZES[@]}"
do
    export BUFFER_SIZE
    echo -e "| Testing with BUFFER_SIZE=${BUFFER_SIZE}..." | tee -a "$LOG_FILE"

    make re > "$RESULTS_DIR/build_${BUFFER_SIZE}.log" 2>&1
    if [ $? -ne 0 ]; then
        echo -e "${RED}Build failed for BUFFER_SIZE=${BUFFER_SIZE}. Check build_${BUFFER_SIZE}.log${RESET}" | tee -a "$LOG_FILE"
        continue
    fi

    TEST_OUTPUT_FILE="$RESULTS_DIR/results_buffer_${BUFFER_SIZE}.txt"
    VALGRIND_OUTPUT_FILE="$RESULTS_DIR/valgrind_buffer_${BUFFER_SIZE}.txt"

    ./gnl_tester > "$TEST_OUTPUT_FILE" 2>&1
    if [ $? -ne 0 ]; then
        echo -e "${RED}BUFFER_SIZE=${BUFFER_SIZE}: Test failed! Check results_buffer_${BUFFER_SIZE}.txt${RESET}" | tee -a "$LOG_FILE"
    fi

    echo -e "Running Valgrind for BUFFER_SIZE=${BUFFER_SIZE}..." | tee -a "$LOG_FILE"
    valgrind --leak-check=full ./gnl_tester > "$VALGRIND_OUTPUT_FILE" 2>&1
    if grep -q "ERROR SUMMARY: [^0]" "$VALGRIND_OUTPUT_FILE"; then
        echo -e "${RED}BUFFER_SIZE=${BUFFER_SIZE}: Memory issues detected! Check valgrind_buffer_${BUFFER_SIZE}.txt${RESET}" | tee -a "$LOG_FILE"
    else
        echo -e "${GREEN}BUFFER_SIZE=${BUFFER_SIZE}: Memory check passed!${RESET}" | tee -a "$LOG_FILE"
    fi
done

echo -e "${PURPLE}==========================================================================${RESET}"
echo "All tests completed! Check the $RESULTS_DIR folder for results! ദ്ദി(˵ •̀ u - ˵ ) ✧ good luck, Wizard!" | tee -a "$LOG_FILE"
echo "________▄▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▄______________________________________________________________"
echo "_______█░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░█_____________________________________________________________"
echo "_______█░▒▒▒▒▒▒▒▒▒▒▄▀▀▄▒▒▒░░█▄▀▀▄_________________________________________________________"
echo "__▄▄___█░▒▒▒▒▒▒▒▒▒▒█▓▓▓▀▄▄▄▄▀▓▓▓█_________________________________________________________"
echo "█▓▓█▄▄█░▒▒▒▒▒▒▒▒▒▄▀▓▓▓▓▓▓▓▓▓▓▓▓▀▄_________________________________________________________"
echo "_▀▄▄▓▓█░▒▒▒▒▒▒▒▒▒█▓▓▓▄█▓▓▓▄▓▄█▓▓█_________________________________________________________"
echo "_____▀▀█░▒▒▒▒▒▒▒▒▒█▓▒▒▓▄▓▓▄▓▓▄▓▒▒█________________________________________________________"
echo "______▄█░░▒▒▒▒▒▒▒▒▒▀▄▓▓▀▀▀▀▀▀▀▓▄▀_________________________________________________________"
echo "____▄▀▓▀█▄▄▄▄▄▄▄▄▄▄▄▄██████▀█▀▀___________________________________________________________"
echo "____█▄▄▀_█▄▄▀_______█▄▄▀_▀▄▄█_____________________________________________________________"