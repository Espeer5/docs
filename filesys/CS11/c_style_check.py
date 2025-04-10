#! /usr/bin/env python3

"""
A simple-minded style checker for C code.
This only catches the most obvious style mistakes, and occasionally
flags stuff that isn't wrong.
"""

import re
import string
import sys

#
# Constants.
#

MAX_LINE_LENGTH = 80

#
# Regular expressions corresponding to style violations.
#

tabs                = re.compile(r"\t+")
comma_space         = re.compile(r",[^ ]")

# This one is really tough to get right, so we settle for catching the
# most common mistakes.  Add other operators as necessary and/or feasible.
operator_space      = re.compile(r"(\w(\+|\-|\*|\<|\>|\=)\w)" + \
                                 r"|(\w(\=\=|\<\=|\>\=)\w)")
comment_line        = re.compile(r"^\s*\/\*.*\*\/\s*$")
open_comment_space  = re.compile(r"\/\*[^ *\n]")
close_comment_space = re.compile(r"[^ *]\*\/")
paren_curly_space   = re.compile(r"\)\{")
c_plus_plus_comment = re.compile(r"\/\/")
semi_space          = re.compile(r";[^ \s]")

def check_line(filename, line, n):
    """
    Check a line of code for style mistakes.
    """
    # Strip the terminal newline.
    line = line[:-1]

    if tabs.search(line):
        print('File: {}, line {}: [TABS]:\n{}'.format(filename, n, line))

    if len(line) > MAX_LINE_LENGTH:
        print('File: {}, line {}: [TOO LONG ({} CHARS)]:\n{}'
                .format(filename, n, len(line), line))

    if comma_space.search(line):
        print('File: {}, line {}: [PUT SPACE AFTER COMMA]:\n{}'
                .format(filename, n, line))

    if operator_space.search(line):
        if not comment_line.search(line):
            print('File: {}, line {}: [PUT SPACE AROUND OPERATORS]:\n{}'
                    .format(filename, n, line))

    if open_comment_space.search(line):
        print('File: {}, line {}: [PUT SPACE AFTER OPEN COMMENT]:\n{}'
                .format(filename, n, line))

    if close_comment_space.search(line):
        print('File: {}, line {}: [PUT SPACE BEFORE CLOSE COMMENT]:\n{}'
                .format(filename, n, line))

    if paren_curly_space.search(line):
        print('File: {}, line {}: [PUT SPACE BETWEEN ) AND {{]:\n{}'
                .format(filename, n, line))

    if c_plus_plus_comment.search(line):
        print('File: {}, line {}: [DON\'T USE C++ COMMENTS]:\n{}'
                .format(filename, n, line))

    if semi_space.search(line):
        print('File: {}, line {}: [PUT SPACE/NEWLINE AFTER SEMICOLON]:\n{}'
                .format(filename, n, line))

def check_file(filename):
    file = open(filename, 'r')
    lines = file.readlines()
    file.close()

    for i in range(len(lines)):
        check_line(filename, lines[i], i + 1)  # Start on line 1.

if __name__ == '__main__':
    usage = 'usage: c_style_check filename1 [filename2 ...]'

    if len(sys.argv) < 2:
        print(usage)
        raise SystemExit

    for filename in sys.argv[1:]:
        check_file(filename)

