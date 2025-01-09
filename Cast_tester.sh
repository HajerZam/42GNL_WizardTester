#!/bin/bash

RESULTS_DIR="buffer_size_tests"
mkdir -p $RESULTS_DIR

# ASCII Art to start the tests
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

echo "Running Mandatory tests be patient ଘ(∩^o^)⊃━☆゜✩₊˚.⋆☾⋆⁺₊✧...."

GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

# Norminette
echo "Checking Norminette compliance ଘ( ･ω･)_/ﾟ･:*:･｡☆..."
NORMINETTE_RESULTS="norminette_results.txt"
norminette > "$NORMINETTE_RESULTS"

if grep -q "Error" "$NORMINETTE_RESULTS"; then
    echo -e "${RED}Norminette check failed! (ง ͠ಥ_ಥ)ง Check $NORMINETTE_RESULTS for details.${RESET}"
else
    echo -e "${GREEN}Norminette check passed! (๑>؂•̀๑)${RESET}"
fi

BUFFER_SIZES=(1 2 4 8 16 32 64 128 256 512 1024 2048 4096 8192)

for BUFFER_SIZE in "${BUFFER_SIZES[@]}"
do
    export BUFFER_SIZE
    TESTER="./gnl_tester"
    RESULT_FILE="$RESULTS_DIR/results_buffer_${BUFFER_SIZE}.txt"
    VALGRIND_FILE="$RESULTS_DIR/valgrind_buffer_${BUFFER_SIZE}.txt"

    echo " now Testing with BUFFER_SIZE=${BUFFER_SIZE}..."

    # Run the program and capture the exit code
    $TESTER > "$RESULT_FILE" 2>&1
    EXIT_CODE=$?

    # Run valgrind
    valgrind --leak-check=full $TESTER > "$VALGRIND_FILE" 2>&1
    VALGRIND_EXIT=$?

    if [ $EXIT_CODE -ne 0 ]; then
        echo -e "${RED}BUFFER_SIZE=${BUFFER_SIZE}: FAILED (ง ͠ಥ_ಥ)ง (Segmentation fault or error)${RESET}"
    elif grep -q "ERROR SUMMARY: [^0]" "$VALGRIND_FILE"; then
        echo -e "${RED}BUFFER_SIZE=${BUFFER_SIZE}: FAILED (｡·  v  ·｡) ? (Memory issues)${RESET}"
    else
        echo -e "${GREEN}BUFFER_SIZE=${BUFFER_SIZE}: PASSED (๑>؂•̀๑)${RESET}"
    fi
done

# ASCII Art to start the tests
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

echo "All tests completed! Check the $RESULTS_DIR folder for results! ദ്ദി(˵ •̀ ᴗ - ˵ ) ✧ good luck, Wizard!"