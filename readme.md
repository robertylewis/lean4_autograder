# Lean 4 autograder shell

This repository provides some scripts to configure a Gradescope autograder for Lean 4.

It does *not* contain the autograder itself.

## Directions for use

1. Edit `config.json` in this repository.
   * `autograder_repo`: a GitHub repository containing a Lean project, with the context for assignment submissions, including a stencil file located at `assignment_path`. Submissions will be compiled with this repository available as an import. Example: [`brown-cs22/CS22-Lean-2024`](https://github.com/brown-cs22/CS22-Lean-2024).
   * `assignment_path`: the path within `public_repo` of the assignment stencil or solutions. Example: `BrownCs22/Homework/Homework01.lean`. So, the assignment stencil for this assignment lives in the [brown-cs22/CS22-Lean-2024](https://github.com/brown-cs22/CS22-Lean-2024) repository, at this path.
  
     This project must have [an autograder](https://github.com/robertylewis/lean4-autograder-main/) as a Lake dependency: e.g. the line `require autograder from git "https://github.com/robertylewis/lean4-autograder-main" @ "f3c4a3eb22cb9377c696085c4c09fcb7e6e7e9ba"` in its lakefile.
2. In order to grade definitions, the autograder needs reference solutions. The file at `assignment_path` should include these solutions. In this case `autograder_repo` is likely private. You can give the autograder access to a private solutions repo by adding a [deploy key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/managing-deploy-keys#deploy-keys) to your private repository.
  
   1.  On a local computer, run `ssh-keygen -t ed25519 -C "your_email@example.com"`. This will generate a public and private key.
   2.  Upload the resulting public key to your repository: `Settings -> Deploy Keys -> Add Deploy Key`. It does not need write access.
   3.  Copy the private key into the root of the directory for the autograder shell, naming it `autograder_deploy_key`. 
  
   If you do not plan to autograde definitions, you can skip this step.
  
3. Run `make_autograder.sh` to create a zip file.
4. Upload this zip file to gradescope. The autograder must be configured to use the maximum available CPU resources.

## Autograder architecture

To repeat, this repository does not contain the autograder itself.
This is a wrapper for the [autograder](https://github.com/robertylewis/lean4-autograder-main/) Lean package.

Submissions are independently verified using
[Comparator](https://github.com/leanprover/comparator), which rebuilds the
submission in a sandboxed subprocess (via
[landrun](https://github.com/Zouuup/landrun)), re-serializes it through
`lean4export`, and replays it through the Lean kernel, rather than trusting
the autograder's own in-process elaboration of the submission. `setup.sh`
builds `landrun` from source and installs it to `/usr/local/bin`, and builds
the `comparator`/`lean4export` binaries alongside the autograder itself.

Note: Comparator's own README recommends wrapping its invocation in
`systemd-run` to fully close one specific known `landrun` vulnerability. This
setup does not do that, relying instead on Gradescope's own per-submission
container isolation as the outer security boundary; `systemd-run` may not
even be usable inside a Gradescope container. If you need the stronger
guarantee, see Comparator's README for the `systemd-run` invocation.
