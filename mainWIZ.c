#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <sys/stat.h>
#include <time.h>
#include "get_next_line.h"

#define TEST_RESULTS_DIR "test_results"

void get_timestamp(char *buffer, size_t size) {
    time_t now = time(NULL);
    struct tm *t = localtime(&now);
    strftime(buffer, size, "%Y-%m-%d_%H-%M-%S", t);
}

void save_test_result(const char *test_name, const char *result) {
    char file_path[256];
    snprintf(file_path, sizeof(file_path), "%s/%s.txt", TEST_RESULTS_DIR, test_name);

    FILE *file = fopen(file_path, "w");
    if (!file) {
        perror("Failed to save test result");
        return;
    }
    fprintf(file, "%s", result);
    fclose(file);
}

void run_test(const char *test_name, const char *file_name, const char *expected_file) {
    int fd = open(file_name, O_RDONLY);
    FILE *expected = fopen(expected_file, "r");

    if (fd == -1 || !expected) {
        perror("Failed to open test or expected output file");
        printf("Test %s: FAILED\n", test_name);
        return;
    }

    char *line;
    char expected_line[1024];
    int line_num = 0;
    int passed = 1;

    char result_path[256];
    snprintf(result_path, sizeof(result_path), "%s/%s_result.txt", TEST_RESULTS_DIR, test_name);
    FILE *result_file = fopen(result_path, "w");
    if (!result_file) {
        perror("Failed to create result file");
        return;
    }

    fprintf(result_file, "Results for %s:\n", test_name);

    while ((line = get_next_line(fd)) != NULL) {
        line_num++;
        if (!fgets(expected_line, sizeof(expected_line), expected)) {
            fprintf(result_file, "Line %d: Unexpected output: %s\n", line_num, line);
            passed = 0;
        } else if (strcmp(line, expected_line) != 0) {
            fprintf(result_file, "Line %d: Expected: %sGot: %s\n", line_num, expected_line, line);
            passed = 0;
        } else {
            fprintf(result_file, "Line %d: PASSED\n", line_num);
        }
        free(line);
    }

    if (fgets(expected_line, sizeof(expected_line), expected)) {
        fprintf(result_file, "Extra line in expected file: %s\n", expected_line);
        passed = 0;
    }

    fclose(result_file);
    fclose(expected);
    close(fd);

    printf("Test %s: %s\n", test_name, passed ? "PASSED" : "FAILED");
}


void run_test_multiple_fds(const char *test_name, const char *file1, const char *file2) {
    int fd1 = open(file1, O_RDONLY);
    int fd2 = open(file2, O_RDONLY);

    if (fd1 == -1 || fd2 == -1) {
        perror("Failed to open test files");
        return;
    }

    char *line1, *line2;
    int read_count = 0;

    char result_path[256];
    snprintf(result_path, sizeof(result_path), "%s/%s_result.txt", TEST_RESULTS_DIR, test_name);
    FILE *result_file = fopen(result_path, "w");
    if (!result_file) {
        perror("Failed to create result file");
        return;
    }

    fprintf(result_file, "Results for %s:\n", test_name);

    while ((line1 = get_next_line(fd1)) || (line2 = get_next_line(fd2))) {
        read_count++;
        fprintf(result_file, "Read %d:\n  File 1: %s\n  File 2: %s\n",
                read_count, line1 ? line1 : "EOF", line2 ? line2 : "EOF");

        free(line1);
        free(line2);
    }

    fclose(result_file);
    close(fd1);
    close(fd2);

    printf("Test %s: Results saved to %s\n", test_name, result_path);
}


int main()
{
    printf("==== get_next_line Tester ====\n");

    struct stat st = {0};
    if (stat(TEST_RESULTS_DIR, &st) == -1) {
        mkdir(TEST_RESULTS_DIR, 0755);
    }
    system("rm -rf test_results/*.txt");

    printf("\n");
    printf("\n==== Mandatory Tests （´∇｀''） ====\n");
    printf("\n");

    run_test("Basic Test", "SpellFiles/wizard_test.txt", "Abracadabra!\n");
    run_test("Empty File", "SpellFiles/empty.txt", "");
    run_test("Multiple Lines", "SpellFiles/multi_lines.txt", "The wizard raised his staff.\n");
    run_test("Single Line", "SpellFiles/single_line.txt", "One spell to rule them all.\n");
    run_test("Single Line with Newline", "SpellFiles/single_line_newline.txt", "The magic begins here.\n");
    run_test("No Newline at EOF", "SpellFiles/no_newline_at_eof.txt", "This spell has no newline at the end");

    printf("\n");
    printf("\n==== Edge Cases ( ｰ̀εｰ́ )====\n");
    printf("\n");

    run_test("Very Long Line", "SpellFiles/very_long_line.txt", 
              "Once upon a time in a magical kingdom far away, there lived a wizard whose spells were so powerful that they could move mountains, calm raging seas, and bring stars down from the heavens with a single word.\n");
    run_test("Special Characters", "SpellFiles/special_characters.txt", "✨🪄✨ Alakazam! 💫⚡\n");

    printf("\n");
    printf("\n==== Large File Test (  •̀ - •́  ) ====\n");
    printf("\n");

    run_test("Large File", "SpellFiles/large_file.txt", "Magicae incantare!\n");

    printf("\n");
    printf("\n==== Bonus Test ====\n");
    printf("\n");

    run_test_multiple_fds("Multiple FDs Test", "SpellFiles/file1.txt", "SpellFiles/file2.txt");

    printf("\n");
    printf("\n==== Additional Test ( ◡̀_◡́)ᕤ ====\n");
    printf("\n");

    run_test("Random Magical Phrases", "SpellFiles/random_phrases.txt", "Accio broomstick!\n");

    printf("\n");
    printf("\n==== Checking Memory Leaks („• ֊ •„)੭ ====\n");
    printf("\n");
    char timestamp[64];
    get_timestamp(timestamp, sizeof(timestamp));

    char valgrind_report_path[256];
    snprintf(valgrind_report_path, sizeof(valgrind_report_path),
             "test_results/valgrind_report_%s.txt", timestamp);

    char valgrind_command[512];
    snprintf(valgrind_command, sizeof(valgrind_command),
             "valgrind --leak-check=full ./gnl_tester > %s 2>&1", valgrind_report_path);

    system(valgrind_command);
    printf("Memory leaks report saved to %s\n", valgrind_report_path);

    return (0);
}