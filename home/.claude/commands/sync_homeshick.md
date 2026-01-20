# Sync Homeshick

Sync dotfile changes to the homeshick dotfiles-castle repo and create a PR.

## Arguments

- `$ARGUMENTS` - Optional: commit message or description of changes. If not provided, will be inferred from the changes.

## Instructions

1. **Check for changes**

   Navigate to the homeshick repo and check for modifications:
   ```bash
   cd ~/.homesick/repos/dotfiles-castle
   git fetch origin
   git status
   ```

   Look for:
   - Untracked files
   - Modified tracked files
   - Deleted files

   If there are no changes, inform the user and stop.

2. **Review the changes**

   For each changed/new file, briefly describe what changed:
   - New files: show the file and summarize its purpose
   - Modified files: show the diff and summarize the changes
   - Deleted files: note what was removed

   Ask the user to confirm they want to proceed with creating a PR for these changes.

3. **Create a branch**

   Create a new branch from origin/master:
   ```bash
   git checkout -b ronco/<descriptive-branch-name> origin/master
   ```

   Use a descriptive branch name based on the changes (e.g., `ronco/add-review-prs-skill`, `ronco/update-zshrc`).

4. **Stage and commit**

   Stage the relevant files:
   ```bash
   git add <files>
   ```

   Create a commit with a conventional commit message:
   - Use `feat(<scope>):` for new features
   - Use `fix(<scope>):` for bug fixes
   - Use `docs(<scope>):` for documentation updates
   - Use `chore(<scope>):` for maintenance changes

   Use an appropriate scope based on what's being changed (e.g., `claude`, `zsh`, `git`, `vim`).

   If `$ARGUMENTS` was provided, incorporate it into the commit message.

5. **Push and create PR**

   Push the branch:
   ```bash
   git push -u origin <branch-name>
   ```

   Then invoke the `/pr` skill to create the PR with a GIF.

6. **Offer to merge**

   After the PR is created, ask if the user wants to merge it immediately:
   ```bash
   gh pr merge <number> --repo ronco/dotfiles-castle --squash --delete-branch
   ```

7. **Clean up**

   After merging (or if the user declines), switch back to master:
   ```bash
   git checkout master
   git pull origin master
   ```
