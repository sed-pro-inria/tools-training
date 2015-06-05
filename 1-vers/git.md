
# Version control with Git

<img src="images/git_commit.png">

**Part 1: Local version control (only one Git repository)**

- The init command
- The add, commit and log commands
- How it works: working copy, staging area (index) and database.
- The diff and status commands
- The log command
- The checkout command
- More on commits
- The SHA-1
- Git branches
- The merge command
- What Git branches are

**Part 2: Centralized (à la cvs/svn) version control**

- The --bare option of the init command
- The remote command
- The push command
- The fetch command
- Remote branches
- Pushing a (feature) branch
- Tracking branch
- Visualizing branches

**Part 3: Distributed workflow**

## Git, a distributed Version Control System

Version control means keeping track of code evolution by recording
the code's state after each meaningful change. This is useful:

  - To cancel a non-working modification
  - To perform regression tests / continuous integration

The database where the different states of the code are recorded can be:

  - Local: the project has only one developer
  - Centralised: it is available on a server but developers do not receive it
when they get the project's sources (cvs, svn).

  - Distributed: every developer that has the sources also has the full code
history (git, mercurial, darcs).


Version Control Manager:

  - Source code is frequently **committed** into Git database, and each
**commit** can be retrieved, shared with team.
  - Keep, search your code history.
  - Develop software in team efficiently.

Distributed:

  - Unlike **SVN** which is **centralized**, **Git** is **distributed**. It
means that Git does not require to use one central repository, but multiple ones
may be used.
  - When one downloads source code from a Git repository, it creates a new Git
repository, with the full database. There is no conceptual difference between
the two repositories.
  - Offline work possibility
  - Multiple possible workflows to collaborate with other developers.

Some terminology:

  - Repository: the vesion-controlled project and optionally the database
containing the project's history.
  - Commit: one record of the code's state in the project's history.
  - Branch: maintain several versions of the project in parallel

**Git** makes it easy to work with **branches**.

  - Branches are easy to create, merge and destroy.
  - Creating temporary branches to develop a feature is encouraged.

**Git** has a few core concepts that must be understood.

   - Without knowing these core concepts, using Git is frustrating and painful.
   - Knowing them, using Git is powerful and easy.

Thanks to Git's simplicity for creating new repositories and managing branches,
a workflow adapted to your team may be chosen. For example:

   - working with a central repository and contributing into branches (small
private teams);
   - working with forks and contributing with pull requests (large teams with
external contributors).

This presentation deals with the core concepts of Git, so as to make its
adoption easier.

## Local version control (only one Git repository)

We start working on a single repository.

In this section, we will learn the core concepts of Git:

    - commits,
    - staging area (index),
    - branches.

Start by creating a new empty directory to experiment with Git:


    from os import makedirs, chdir, curdir, walk, sep
    from os.path import expanduser, isdir, abspath, join, relpath, basename
    from shutil import rmtree
    
    workdir = expanduser('~/git-training')
    
    # Remove possible existing working, and starts with a fresh one.
    if isdir(workdir):
        rmtree(workdir)
    makedirs(workdir)
    
    def changedir(directory):
        """Set up a directory relative to workdir"""
        directory = abspath(join(workdir,directory))
        if not isdir(directory):
            makedirs(directory)
        chdir(directory)
        print("We are in directory " + directory)
        
    # The directory that will contain the Git repository
    changedir('repo')

### Configuring Git

It is imporant to configure a few things (name, e-mail, editor)
before starting to use Git. This is done thanks to the following commands:

git config --global user.name "Firstname Lastname"

git config --global user.email firstname.lastname@inria.fr

git config --global core.editor vim

Note: we used the **--global** flag here so that the configuration applies
to all repositories (it's stored in ~/.gitconfig). It is also possible
to use the **--local** flag to make a configuration
repository-specific (stored in ~/repository-path/.git/config). A
repository-specific configuration overloads the default configuration.

### The init command

A Git **repository** is created in the current directory using the **init**
command.

This will create a `.git` hidden directory, where Git stores its database.


    %%bash
    
    git init
    ls -la

You can now start developing. For example, we may write "First Line" in a file
called ``foo.txt``. But in practice, we would probably want to write some real
source code.


    %%bash
    
    echo "First line" > foo.txt

### The add, commit and log commands

To record (commit) the previous changes to Git's database, do as follows:


    %%bash
    
    git add foo.txt
    git commit -m "Initial commit."  

The **add** command tells Git to track changes in the file ``foo.txt``
and says that the current content of this file should be commited by
the next **commit** command.

The **commit** command itself then records (commits) all the added
changes to git's database and associates a few metadata to this
set of changes.

The argument of -m is a commit message, that is, a description of the
commited change. The commit message is mandatory. If -m is not given,
the **commit** command will open an editor where the commit message
should be typed.

To make sure things have been properly commited, one may use the
**log** command:


    %%bash
    
    git log

### How it works: working copy, staging area (index) and database.

Woking copy and database are conceps which are well known in other
revision control systems. To these, Git adds a third zone, the
staging area. It is an intermediary place where changes go before
being commited to Git's database.

Having this third area may seem odd at first, but it turns out to be
useful e.g. to seperate commits, as we will see.

Suppose we add two lines to foo.txt:


    %%bash
    
    echo "Second line" >> foo.txt
    echo "Third line" >> foo.txt

But then we realise that these two lines really represent two distinct
changes and should thus be commited separately.

Git makes it possible to achieve this thanks to its index or staging
area, like this:


    %%bash
    
    #git add -p foo.txt

And choose 'e' to edit the hunk, then remove the line

+Third line

so that the only line starting wih a + symbol "Second line".

To make sure only the second line has been added to the index and will
thus be commited, use the **diff** command as follows:


    %%bash
    
    git diff --cached

Before continuing, notice how we now have three different versions of
foo.txt:

- One in the working copy (3 lines)
- One in the index (2 lines)
- One in the database (1 line)

Let's commit what has been staged:


    %%bash
    
    git commit -m "Second commit" 

Let's make sure the commit has worked:


    %%bash
    
    git log

And note that the staging area is now empty:


    %%bash
    
    git diff --cached

We can now commit our second change to foo.txt:


    %%bash
    
    git add foo.txt
    git commit -m "Third commit"

Two remarks are due here:

1. The example we have jsut seen to understand why the staging area is
useful is quite artificial. It is however rather imortant, because
the situation it describes can happen quite a lot in practice. For
instance, suppose that while adding a feature to a program one
discovers typos in the existing code. The new
feature and the typo fixups could for sure be commited together,
but doing two distinct commits is considered better practice because
it gives a cleaner history (In particular, should the feature be removed
later, that could be achieved without loosing the typo fixups.)

In such a situation, the -p flag to the add
command turns out to be especially useful. Moreover, since the
changes happen most of the time in different hunks (regions), it will
be easier to use the interactive **add** in such situations than in
the one above, since it will not require any manual hunk edition as before.


2. The three areas that have just been introduced (working copy,
staging area and commit database) are of crucial importance. Indeed,
almost all git commands either
manipulate one of these areas or transfer content between two
of them and understanding Git in terms of how the commands work on areas
turns out to be especially helpful (if not fundamental) in practice.

Moreover, for one specific command, its arguments may change the areas
it affects. As an example, git commit transfers content from the
staging area to the database, but with the -a argument, the same command
will transfer all the uncommited (and unstaged) changes directly from
the working copy to the database and leave the staging area unmodified.

Exercise: can you explain what **log** and **add** do in terms of
the three areas?

### The diff and status commands

Modify the ``foo.txt`` file, and observe the outputs of the **diff** and
**status** commands


    %%bash
    
    echo 'Fourth line' >> foo.txt


    %%bash
    
    git diff


    %%bash
    
    git status

Stage the file, and observe the new outputs of the **diff** and **status**
commands


    %%bash
    
    git add foo.txt


    %%bash
    
    git diff


    %%bash
    
    git diff --cached


    %%bash
    
    git status

Commit the file.


    %%bash
    
    git commit -m 'Add fourth line to foo.txt'

### The log command

The **log** command prints an history of all the commits.


    %%bash
    git log


    %%bash
    git log -p

A common practice when writing commit messages is to start with a
one-line description of the commit, optionally followed by a longer
description which may be split into several paragraphs.

Another thing one may do when writing commit messages is to explain
more why the change is done than the change itself, since the change
can be figured out by studying the patch itself.

### The checkout command

The **checkout** command updates files in the working tree to match the version
in the index or the specified tree. For example:



    %%bash
    git checkout master^

Will ask Git to set-up the working copy according to the content of
Git's database at commit master^, namely one commit before master as
indicated by the ^ postfix operator.

Let's verify:


    %%bash
    cat foo.txt

And now let's restore the working copy as it was before this checkout:


    %%bash
    git checkout master

And let's verify that this worked, too:


    %%bash
    cat foo.txt

### More on commits

To take advantage of all the powerful features of Git, it is important to
understand what a **commit** actually is.

The first thing to know is that Git has stored in its database 1 commit
object,for each commit, each commit object containing a complete
version of the ``foo.txt`` file.

  - For the first commit, Git has stored in its database a commit object
containing ``First line``.
  - For the second commit, Git has stored in its database a commit object
containing not the difference between the two versions, but the whole file:
``First line`` (hence duplicated in Git's database), and ``Second line``.
  - After the second commit, ``First line`` **is** duplicated in the 2
different commit objects in Git's database.

Note that for performance, Git has the ability to efficiently compress its
database and handle differences only (especially during network transfer),
but the model is to store the whole content of files for each commit, as
opposed to some other revision control systems which only store differences.

This yields a very simple model. A commit contains the directories and files we
have commited (called ``tree`` and ``blob`` in Git), plus some metadata.

In Git, a commit object contains:

  - At least one parent commit (except for the initial commit)
  - The (root) tree (which itself contains trees and blobs).
  - The commit message.
  - The author.
  - The commit date.

### The SHA-1

With Git it is not possible to assign integer numbers to commits in a
sequential way as is done in svn for instance, because Git's distributed
nature and branches make the very notion of linear sequence vanish.

Git uses the **SHA-1** cryptographic hash function to identify each object
(**commit**, **tree**, **blob**) with a hash value. Such a hash value may look
like the following one:  ``0e1e060688a560015614cf7ec4b77d8a0df07c2f``.

The hash value is computed from the object's content. It is very
unlikely that two diferent commit objects have the same
**SHA-1** hash value. The likelihood of such collisions is so low that it
is generally considered to be 0, meaning that in practice it is
considered that having same SHA-1 hash and being the same commit are
equivalent propositions.

Each hash value identifies only one commit. It also identifies all the
directories and files that belong to the commit. Note that parent commits are
also part of the commit: two commits sharing the same files and directories,
but with different commit parents, will have different hash values.

Note:

  - if two developpers create exactly the same commit on two different
computers, the hash value will be the same,
  - we know that two commits are different by only comparing their hash values,
  - hash value are very fast to compute: if a whole tree in a commit has not
changed, Git does not have to recompute its hash again.

### Git branches

Suppose we now want to try developing a new feature in our code, while
continuing our previous work on ``foo.txt``.

Git encourages creating a branch for this.

A branch is created with the **branch** command, followed by a branch **name**:


    %%bash
    
    git branch bar

Without any argument, the **branch** command lists all the branches and marks
the current one with an asterisk (git status also displays the current branch).


    %%bash
    
    git branch

The **checkout** command allows you to switch to another branch:


    %%bash
    
    git checkout bar
    git branch

It is very important to remember that git branch b creates branch b but
does not change the current branch. This is similar to Unix's mkdir
command which creates a new directory without changing the current
directory to the one it just created. To continue the analogy with Unix
commands, git checkout b changes the current branch in the same way
cd changes the current directory.

It is however common when creating a branch that the intention is to
switch to that branch right after it has been created and this is what
the git checkout -b command does. In other words, what had been achieved
in two steps before (namely git branch bar and git checkout bar) can
be achieved with just the following command: git checkout -b bar.

Now, let us develop different things in the two branches:


    %%bash
    
    echo 'First line' > bar.txt
    git add bar.txt
    git commit -m 'First line of bar.txt'
    
    echo 'Second line' >> bar.txt
    git add bar.txt
    git commit -m 'Second line of bar.txt'
    
    git checkout master
    echo "Fifth line" >> foo.txt
    git add foo.txt
    git commit -m  'Fifth line of foo.txt'
    
    echo "Sixth line" >> foo.txt
    git add foo.txt
    git commit -m 'Sixth line of foo.txt'
    
    git checkout bar
    echo 'Third line' >> bar.txt
    git add bar.txt
    git commit -m 'Third line of bar.txt'

### The merge command

We merge the work of the two branches. More specifically, we merge the **bar**
branch into the **master** branch


    %%bash
    
    git checkout master
    git merge bar

Because there is no conflict, the merge is performed automatically. In case of
confict (same lines of a file modified in both branches):

   - the merge operation stops,
   - the developper edits the conflicting files to solve the conflict,
   - the developper commits the merged files.

### What Git branches are

Edit the file ``~/.gitconfig`` and add the content:

    [alias]
      gr = log --graph --full-history --all --color
--pretty=tformat:"%x1b[31m%h%x09%x1b[32m%d%x1b[0m%x20%s%x20%x1b[33m(%an)%x1b[0m"

This adds a useful **gr** command to Git, that displays a colored graph of the
branches.


    %%bash
    
    git gr

All the commits form a chain, in which each commit is linked to its parent(s).

Creating a branch means having two commits with the same parent, while merging
means creating a commit with two parents.

We can now give a simple definition of a branch: a symbolic name that points to
a commit with no children.

Two special branches are:

   - **master**, the original branch when a repository is created. That's a
branch like the others.
   - **HEAD**, the current branch, which is updated after each commit
   (like $PWD in Unix shells).

When a commit is checked out that is not the end of a branch (has
children), it is said that the repository is in "detached head" mode. In
that state, it is possible to create commits which will be linked to tehe
one that has been checked out, but it must be kept in mind that no
symbolic name (apart from HEAD) will be associated with the last commit,
so when HEAD moves to a different branch the repo wil have a branch with
no symbolic name associated to its tip and which may hence be
garbage-collected later by Git. It is however possible and easy to
associate a symbolic name with a commit at any time with the git
branch command.

Note: with this knowledge on commits and branches, some Git features not
demonstrated here will be easy to understand:
    - rebase
    - fast-forward
    - tags (symbolic names which don't move, as opposed to branches)

## Exercice

During the exercice, experiment with `git log`, `git status`, `git gr`, etc.

0- Initialize an empty Git repository (remember, you have to create the
repository's directory and to change to that directory!).

1- Create a script `main.py` with the following content, and commit it.


    #!/usr/bin/env python
    
    def greet():
        print("Hello world!")
    
    greet()

2- Modify the script, commit it


    #!/usr/bin/env python
    
    def greet(name):
        print("Hello %s!" % name)
    
    greet("Alice")

3- Modify and commit the script again.


    #!/usr/bin/env python
    import sys
    
    def greet(name):
        print("Hello %s!" % name)
    
    if len(sys.argv) > 1:
        greet(sys.argv[1])
    else:
        sys.stderr.write("Usage: %s NAME\n" % sys.argv[0])
        sys.exit(1)

4- In a branch `format_name`, modify and commit the script:


    #!/usr/bin/env python
    import sys
    
    def greet(name):
        print("Hello %s!" % name.capitalize())
    
    if len(sys.argv) > 1:
        greet(sys.argv[1])
    else:
        sys.stderr.write("Usage: %s NAME\n" % sys.argv[0])
        sys.exit(1)

5- In the `master` branch, modify the script and commit:


    #!/usr/bin/env python
    import sys
    
    def greet(name):
        print("Hello %s! How are you?" % name)
    
    if len(sys.argv) > 1:
        greet(sys.argv[1])
    else:
        sys.stderr.write("Usage: %s NAME\n" % sys.argv[0])
        sys.exit(1)

6- Merge the `format_name` branch. You will have to resolve a conflict,
and then commit

Note: once all the conflicts in a file have been resolved, just add and
comit that file. There is no need to run the **merge** command again
to complete the merge or whatever.  

## Centralized (à la cvs/svn) version control

Now that we have learned how to work with a single Git repository, we will learn
how to send/receive commits between two Git repositories

In this section, we will assume a workflow with two developpers: Alice
and Bob. Both of them have their own repository on their computer:

    - Alice's repository A on her computer,
    - Bob's repository B on his computer.

and a central repository on a computer which both Alice and Bob can communicate
with:

    - central repository C on a "server".

For simplicity, we will demonstrate the commands on the same machine, using Git
**file://** protocol. However, Git commands would be **exactly the same**, but
using instead the **ssh://** or **https://** protocols.

Note that configuring a "server" machine to host a Git repository and managing
user permissions, backup, availability, Web views of the repository, etc. is not
easy. Forges like **Inria's GForge**, **GitHub**, **Bitbucket**, **Gitorious**
should be preferred.


    changedir('')

### The --bare option of the init command

We start by creating a central repository.

There is a subtlety. Suppose we create a git repository in ``~/git-
training/central`` and that someone else edits files in this Git repository.

It is possible that someone else sends commits (in Git, this is called **push**)
to this repository, which would be stored in ``~/git-training/central/.git``.
Then Git's database and working copy would differ.

To avoid this situtation, Git provides the **--bare** option to **init**. It
creates a Git repository, but without a working copy. Nobody can **commit**
directly into this repository, but only **push** commits.

Never **push** commits to a Git repository that is not **bare**, to avoid
inconsistencies with its working copy.

By convention, **bare** repositories are suffixed with **.git**, even if it is
not necessary.


    %%bash
    
    git init --bare central.git
    ls -l central.git

Alice clones the central repository:


    %%bash
    
    git clone file://$PWD/central.git alice

Alice enters her Git repository and configures her name and email for
that repository (we assume here she didn't do it at the global level, to
keep all the examples self-contained):


    changedir('alice')


    %%bash
    
    git config --local user.name "Alice"
    git config --local user.email alice@inria.fr

### The remote command

Without argument, the *remote* command lists the **remote** repositories Git
knows about:


    %%bash
    
    git remote

When the central repository has been cloned, Git has given it the name
**origin**, by convention.

Later, we will learn how to register additionnal remote repositories.

Alice works and commits into her repository:


    %%bash
    
    echo 'First line' > foo.txt
    git add foo.txt
    git commit -m 'First line of foo.txt'
    
    echo 'Second line' >> foo.txt
    git add foo.txt
    git commit -m 'Second line of foo.txt'

### The push command

Now, Alice wants to send her commits to the central repository, so that Bob can
get them.

To do so, she uses the **push** command, whose arguments are:

    git push <remote_name> <local_branch>:<remote_branch>

The remote_name is **origin**, Alice pushes the **master** branch of her
repository to the **master** branch of the central repository:


    %%bash
    
    git push origin master:master

Bob now clones the central repository too, enters it and configures his name and
email:


    changedir('')


    %%bash
    
    git clone file://$PWD/central.git bob


    changedir('bob')


    %%bash
    
    git config --local user.name "Bob"
    git config --local user.email bob@inria.fr

Doing so, Bob fetches Alice's work.


    %%bash
    
    git log

Bob makes some changes, commits and pushes:


    %%bash
    
    echo "Third line" >> foo.txt
    git add foo.txt
    git commit -m "Third line to foo.txt"
    git push origin master:master

### The fetch command


    changedir('alice')

Alice wants to get Bob's commits. She
uses the **fetch** command, which donwloads all the commits of all branches from
a remote repository.


    %%bash
    
    git fetch origin

### Remote branches

The git **branch** command lists all branches of Alice's repository, also known
as local branches:


    %%bash
    
    git branch

But where are the **central** repository branches which have just been fetched?

Adding the **-a** option to the **branch** command reveals them:


    %%bash
    
    git branch -a

``remotes/central/master.git`` is called a **remote branch**.

A **remote branch** is a read-only branch that reflects the state of a branch of
a remote repository. If the branch changes on the remote repository, use
**fetch** again to refresh it.

Note: to see only remote branches rather than all branches one can use the -r
flag instead of -a:


    %%%bash
    
    git branch -r

To get all commits of ``remotes/central/master`` **remote branch** into the
**master** branch, merge it:


    %%bash
    
    git merge remotes/origin/master

Note: **fetch** and **merge** operations can be accomplished in one command,
**pull**:

    git pull <remote_name> <remote_branch>:<local_branch>

### Pushing a (feature) branch

While Alice and Bob are working on the master branch, Alice wants to develop an
experimental feature.

She creates a branch for this, and works in it:


    %%bash
    
    git checkout -b exp
    
    echo "First line" > bar.txt
    git add bar.txt
    git commit -m 'First line of bar.txt'
    
    echo "Second line" >> bar.txt
    git add bar.txt
    git commit -m "Second line in bar.txt"

Alice then pushes her branch to a similarly named branch of the central
repository:


    %%bash
    
    git push origin exp:exp

### Tracking branch

At the same time, Bob has worked on the master branch:


    changedir('bob')


    %%bash
    
    echo "Third line" >> foo.txt
    git add foo.txt
    git commit -m "Third line in foo.txt"
    
    echo "Fourth line" >> foo.txt
    git add foo.txt
    git commit -m "Fourth line in foo.txt"

Bob wants to see Alice's work on the ``exp`` branch. He fetches all branches of
the central repository:


    %%bash
    
    git fetch
    git branch -r

Bob has remote branch ``central/exp``, but how to work with it?

Adding the **--track** option to the **checkout** command makes Git create a
**tracking branch**:


    %%bash
    git checkout --track origin/exp

A tracking branch is our local copy of a remote branch. Unlike the remote
branch, we have write access to it.

Tracking branches can also be used to call the **pull** and **push** commands
without arguments.

Note that Alice and Bob can work on the ``exp`` branch without changing anything
to the ``master`` branch.

  - if ``exp`` was not a good idea, the branch can be dropped,
  - if ``exp`` is a good idea, it may be merged into the ``master`` branch.

### Visualizing branches

Bob  helps Alice to develop the ``exp`` branch by making a new commit:


    %%bash
    
    echo "Third line" >> bar.txt
    git add bar.txt
    git commit -m "Third line in bar.txt"

At this point, it is instructive to visualize the different branches:


    %%bash
    
    git gr

We note that:

    - Bob's master branch has 2 more commits than the central one.
    - Bob's exp branch has 1 more commit that the central one.

The verbose option of **branch** is useful to see tracking branches:


    %%bash
    git branch -avv

Bob pushes the commits of the two branches.


    %%bash
    git push origin exp:exp
    git push origin master:master


    %%bash
    
    git gr

Finally, the ``exp`` branch is merged into master. The merge commit is pushed to
the central repository, and the exp branch is deleted:


    %%bash
    
    git checkout master
    git merge exp
    git push origin master:master
    git branch -d exp
    git push origin :exp
    git gr

## Distributed workflow          

Committing to a central repository is okay for small teams where developpers
know and trust each other. For larger projects, though, it is blocking
and dangerous to give write access to the project's main repository
to an external contributor.

Since Git is a distributed revision control system, clloning a
repository means creating a copy of that repository that has exactly
as much information. This opens the road to a workflow different from the
previous one, where each developer has a public repository from which
everybody can read. When this developer wants to share code, he/she
pushes the code to be shared to his/her public repository and informs
the maintainers of the project that there is some code available that
may beintegrated to the project. The maintainers review the code and, if
they find it useful, integrate it to the project's main code base.

This workflow is made possible by the way Git has been designed. The
GitHub platform provides two mechanisms (fork and pull request) that
help developers adopting this workflow, but the workflow itself relies
only on Git features and does not require GitHub to be implemented.

When a developper wants to contribute to a project, he/she forks the original
bare repository. It means that the developper gets his own bare repository. In
this repository, he develops a feature in a branch. When the work is done, he
asks an administrator to pull the feature branch from his repository to the
master
branch of the project's main repository.

In GitHub terminology, this is called a **pull request**.

Let us see this in practice by adding **Emma** as a developper to our previous
example.


    changedir('')

Emma starts by forking the central repository to her own bare repository.

Note: this is a functionnality provided out of the box by GitHub.

Then Emma clones her bare public repository.


    %%bash
    
    git clone --bare central.git central-emma-fork.git
    
    git clone central-emma-fork.git emma


    changedir('emma')


    %%bash
    
    git config --local user.name "Emma"
    git config --local user.email emma@inria.fr

Emma creates a topic branch, works on it, and pushes it to her public
repository:


    %%bash
    
    git checkout -b baz
    
    echo "First line" > baz.txt
    git add baz.txt
    git commit -m 'First line in baz.txt'
    
    echo "Second line" >> baz.txt
    git add baz.txt
    git commit -m 'Second line in baz.txt'
    
    git push origin baz:baz


    changedir('alice')

The next step for Emma is to ask Alice to get the **baz** branch from
**central-emma-fork** pulled into the **master** branch of **central**.

Note: GitHub provides functionnality to request a pull, and review the
associated code.

Alice fetches Emma's bare repository. To do this, she first adds Emma's bare
repository to the list of her remote repositories.


    %%bash
    
    git remote add emma file://$HOME/git-training/central-emma-fork.git
    git fetch emma

At this point, Alice and Emmma can interact with each other to add more commits
to the ``baz`` branch. When her work is done, Alice merges it to ``master``, and
``pushes``.


    %%bash
    
    git checkout master
    git merge emma/baz
    git push origin master:master

## Exercice

This exerice continues on the previous one, and re-uses its Git repository. This
will be the repository of the first developer.

0- Create a bare repository for the first developer.

Hint: beware to the difference between **init** and **clone** in terms
of directories. **init** creates the repository in the current directory,
meaning that the .git directory will be created in the directory from which
the command is invoked. **clone** creates a directory for the cloned
repository and the .git directory will be created in that directory.

1- Push existing commits to this repository.

2- Set up a bare repository and a fork for a second developer.

3- The second developer creates a feature branch, and pushes it to its bare
repository.

4- The first developer gets the feature branch of the second developer, and
pushes it to its bare repository.

## References

> http://www.git-scm.com/docs

> http://githowto.com

> "Version Control with Git, Powerful tools and techniques for collaborative
software development" By Jon Loeliger, Matthew McCullough

> HitHug let's you learn Git through a nice game:
  https://github.com/gazler/githug

> Another game: https://github.com/jlord/git-it

> Make your shell prompt git-aware: https://www.github.com/nojhan/liquidprompt
