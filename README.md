# `${HOME}/.dotfiles`

Version control for dotfiles and templates.

## Purpose

`${HOME}/.config` and `${HOME}` are a nightmare to version control. Maintaining a distinct dotfile directory then linking to those files is a much more sane way to cordon them off from the rest of the mess.

The purpose of this repository is to be able to version control just the configuration files that you care about within the repository, then symlink them to the location where they are actually used. 

## usage

Treat this directory as if it is `${HOME}` and place all config files in the appropriate subdirectory within this path. For instance, configuration files that are expected to be within `${HOME}` itself (eg. `.bashrc`) should be in the root of this repository. Files which should be in `${HOME}/.config` should be placed in the `.config` sub-directory of this repository.

### symlinks.sh

The script `symlinks.sh` can be used to create any links that don't exist so that you don't need to bother manually linking items from this directory.

#### `-d` dry run flag

You can run with the `-d` flag to perform a 'dry run' to see which actions will be taken without actually taking them.

#### .linkignore

Some files and directories are not used directly and don't need to be linked. Put the file or directory name into a file call `.linkignore` within the directory where they exist in order for `symlinks.sh` to skip them. `.linkignore` files themselves are automatically skipped.

#### Conflicting files and directories

If a file with the same name already exists at the expected symlink destination it will be renamed to `filename.bk` and the link will be created using the original filename.

If a directory already exists (eg. `${HOME}/.config`) then the contents of that directory within the repository will be linked instead. Combining this with the renaming behaviour above can result in unnecessarily duplication of an entire directory structure.

You should ensure that you remove one version of any configurations that exist in both the source and destination before running the script. Use the dry run flag to confirm that it will behave as you expect.
