# Lean 4 autograder shell

This repository provides some scripts to configure a Gradescope autograder for Lean 4.

It does *not* contain the autograder itself.

## Directions for use

1. Edit `config.json` in this repository.
   * `public_repo`: a GitHub repository that contains the assignment stencil, with properly commented problems and point values. Example: `robertylewis/leanclass`
   * `assignment_path`: the path within `public_repo` of the assignment stencil. Example: `BrownCs22/Exercises/submission.lean`. So, the assignment stencil for this assignment lives [here](https://github.com/robertylewis/leanclass/BrownCs22/Exercises/submission.lean).
   * `autograder_repo`: a GitHub repository containing a Lean project, with the context for assignment submissions. Most likely, this is the same as `public_repo`. Submissions will be compiled with this repository available as an import. 
  
     This project must have [an autograder](https://github.com/robertylewis/cs22-lean-autograder/) as a Lake dependency: e.g. the line `require autograder from git "https://github.com/robertylewis/cs22-lean-autograder" @ "f3c4a3eb22cb9377c696085c4c09fcb7e6e7e9ba"` in its lakefile.
2. Run `make_autograder.sh` to create a zip file.
3. Upload this zip file to gradescope.

## Autograder architecture

To repeat, this repository does not contain the autograder itself.
This is a wrapper for the [autograder](https://github.com/robertylewis/cs22-lean-autograder/) Lean package.