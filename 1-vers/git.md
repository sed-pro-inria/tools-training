
# Version control

<img src="images/git_commit.png">

## Git, a distributed Version Control Manager

Version control means keeping track of code evlolution by recoding
the code's state after each meaningful change. This is useful:
  - To cancel a non-working modification
  - To perform regression tests / continuous integratino

The database where the different states of the code are recorded can be:
  - Local: the project has only one developer
  - Centralised: it is available on a server but developers do not
receive it when the get the project's sources (cvs, svn).
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
  - Create temporary branches to develop a feature is encouraged.

**Git** has a few core concepts that must be understood.
   - Without knowing these core concept, using Git is frustrating and painful.
   - Knowing them, using Git is powerful and easy.

Thanks to Git's simplicity for creating new repositories and managing branches,
a workflow adapted to your team
may be chosen. For example:
   - working with a central repository and contributing into branches (small
private teams);
   - working with forks and contributing with pull requests (large teams with
external contributors).

This presentation deals with the core concepts of Git, so as to make its
adoption easier.

## Local version control (only one Git repository)

We start working on a repository alone.

In this section, we will learn the core concepts of Git:
    - staging area,
    - commits,
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

As can be seen, the metadata associated with the commit includes its
author. However, the name or e-mail address printed at the moment
may not look so pretty. Here is how to improve this for future
commits:


    %%bash
    
    git config --global user.name "Prénom Nom"
    git config --global user.email prenom.nom@inria.fr

It is even possible to fix the authorship of our previous commit:


    %%bash
    
    git commit --amend --reset-author 

And let's make sure this actually worked:


    %%bash
    
    git log

## How it works: working copy, staging area (index) and database.

Woking copy and database are conceps which are well known in other
revision control systems. To these, Git adds a third zone, the
staging area. It is an intermediary place where changes go before
being commited to Git's database.

Having this third area may seem odd at first, but it turns out to be
useful e.g. to seperate commits, as we will see.

Suppose we add two lines to foo.xtx:


    %%bash
    
    echo "Third line" >> oo.txt
    echo "Fourth line" >> foo.txt

But then we realise that these two lines really represent two distinct
changes and should thus be commited separately.

Git makes it possible to achieve this thanks to its index or staging
area, like this:


    %%bash
    
    git add -p foo.txt

And choose 'e' to edit the hunk, then remove the line

+Fourth line

so that the only +line is +Third line.

To make sure only the third line has been added to the index and will
thus be commited, use the **dif** command as ollows:


    %%bash
    
    git diff --cached

Before continuing, see how we now have three different versions of
foo.txt:

- One in the working copy (4 lines)
- One in the index (3 lines)
- One in the database (2 lines)

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

1. The example we have jsut seen to understand why the staging area is useful is
quite
artificial. It is however rather imortant, because the situation
it describes can happen quite a lot inpractice. For instance, one fixes
typos while adding a feature to a program. The new feature and tye
typo fixups could or sure be commited together, but doing two
distinct ommits is considered better practice because it gives a
cleaner history. In such a situation, the -p flag to the add
command turns out to be especially useful. Moreover, since the
changes happenmost of the time in different hunks, it will be easier
to use the interactive **add** in sch situations tan in the one above,
since it will not require any manual hunk edition as before.

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
    
    echo 'Fifth line' >> foo.txt


    %%bash
    
    git diff


    %%bash
    
    git status

Stage the file, and observe the new output of the **diff** and **status**
commands


    %%bash
    
    git add foo.txt


    %%bash
    
    git diff


    %%bash
    
    git diff --cached


    %%bash
    
    git status

    On branch master
    Changes to be committed:
      (use "git reset HEAD <file>..." to unstage)
    
    	modified:   foo.txt
    


Commit the file.


    %%bash
    
    git commit -m 'Add fifth line to foo.txt'

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

The **checkout** command restores a previous commit. We are in a ``detached
HEAD`` state, which will be explained later in the ``Git branches`` section.


    %%bash
    git checkout master^


    %%bash
    cat foo.txt

    First line
    Second line



    %%bash
    git checkout master


    %%bash
    cat foo.txt

### Git commits

To take advantage of all the powerful features of Git, it is important to
underdand what a **commit** actually is.

The first thing to know is that Git has stored in its database 2 commit objects,
each of them containing a complete version of the file ``foo.txt``.
  - For the first commit, Git has stored in its database a commit object
containing ``First line`` and ``Second line``.
  - For the second commit, Git has stored in its database a commit object
containing not the difference between the two versions, but the whole file:
``First line`` and ``Second line`` (hence duplicated in Git's database) and
``Third line``.
  - After the second commit, ``First line`` **is** duplicated in the 2 different
commit objects in Git's database.

Note that for performance, Git has the ability to efficiently compress its
database and stor differences only (especially during network communication),
but the model is to store the whole content of files for each commit.

This yields a very simple model. A commit contains the directories and files we
have commited (called ``tree`` and ``blob`` in Git), plus some metadata.

In Git, a commit object contains:
  - One parent commit (or more).
  - The (root) tree (which itself contains trees and blobs).
  - The commit message.
  - The author.
  - The commit date.

### The SHA-1

Git uses the **SHA-1** cryptographic hash function to identify each object
(**commit**, **tree**, **blob**) with a hash value. Such a hash value may look
like the following one:  ``0e1e060688a560015614cf7ec4b77d8a0df07c2f``.

The hash value is computed from the object's content. It is almost impossible
that **SHA-1** gives the same hash value for two different contents. The risk of
collision is almost zero, and we consider it to be zero.

Each hash value identifies only one commit. It also identifies all the
directories and files that belong to the commit. Note that parent commits are
also part of the commit:  two commits sharing the same files and directories,
but with different commit parents, will have different hash values.

Note:
  - if two developpers create exactly the same commit on two different
computers, the hash value will be the same,
  - we know that two commits are different by only comparing their hash values,
  - hash value is very fast to compute: if a whole tree in a commit has not
changed, Git does not have to recompute it.

### Git branches

Suppose we now want to try developing a new feature in our code, while
continuing our previous work on ``foo.txt``.

Git encourages creating a branch for this.

A branch is created with the **branch** command, followed by a branch **name**:


    %%bash
    
    git branch bar

Without any argument, the **branch** command lists all the branches and marks
the current one with an asterisk.


    %%bash
    
    git branch

The **checkout** command allows you to switch to another branch:


    %%bash
    
    git checkout bar
    git branch

Now, let us develop something in the two branches:


    %%bash
    
    echo 'First line' > bar.txt
    git add bar.txt
    git commit -m 'First line of bar.txt'
    
    echo 'Second line' >> bar.txt
    git add bar.txt
    git commit -m 'Second line of bar.txt'
    
    git checkout master
    echo "Fourth line" >> foo.txt
    git add foo.txt
    git commit -m  'Fourth line of foo.txt'
    
    echo "Fifth line" >> foo.txt
    git add foo.txt
    git commit -m 'Fifth line of foo.txt'
    
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
   - the developper edits the conflicted files, and solves the conflict,
   - the developper commits the merged files.

### What Git branches are

Edit the file ``~/.gitconfig`` and add the content:

    [alias]
      graph = log --graph --full-history --all --color
--pretty=tformat:"%x1b[31m%h%x09%x1b[32m%d%x1b[0m%x20%s%x20%x1b[33m(%an)%x1b[0m"

This will addde a useful **gr** command to Git, that displays a colored graph of
the branches.


    %%bash
    
    git graph

All the commits form a chain, in which each commit is linked to its parent.

Creating a branch means having two commits with the same parent, while merging
means creating a commit with two parents.

We can now give a simple definition of a branch : their are just a
reference/pointer/name for a given commit.

Two special branches are:
   - **master**, the original branch when a repository is created. That's a
branch like the others.
   - **HEAD**, the current branch, which is updated after each commit.

The situation of a **detached HEAD** seen above means restoring an old commit,
while leaving HEAD pointing to the commit we were on.

Note: with this knowledge on commits and branches, some Git features not
demonstrated here will be easy to understand:
    - rebase
    - fast-forward
    - tag

## Centralized version control

Now that we have learned how to work with a single Git repository, we will learn
how to send/receive commits between two Git repositories

In this section, we will assume a workflow with two developpers:
    - Alice,
    - Bob,

both of them having their own repository on their computer:
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


    changedir(workdir)

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

By convention, **bare** repositories are suffixed with **.git**, even i it is
not necessary.


    %%bash
    
    git init --bare central.git
    ls -l central.git

Alice clones the central repository:


    %%bash
    
    git clone file://$PWD/central.git alice

Alice enters her Git repository


    changedir('alice')

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


    changedir(workdir)

Bob now clones the central repository too:


    %%bash
    
    git clone file://$PWD/central.git bob


    changedir('bob')

Doing so, he fetches Alice's work.


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

But where are the **central** repository branches which have just been
downloaded?

Adding the **-a** option to the **branch** command reveals them:


    %%bash
    
    git branch -a

``remotes/central/master.git`` is called a **remote branch**.

A **remote branch** is a read-only branch that reflects the state of a branch of
a remote repository. If the branch changes on the remote repository, use
**fetch** again to refresh it.

To get all commits of ``remotes/central/master`` **remote branch** into the
**master** branch, merge it:


    %%bash
    
    git merge remotes/origin/master

Note: **fetch** and **merge** operations can be accomplished in one command,
**pull**:

    git pull <remote_name> <remote_branch>:<local_branch>

### Pushing a feature branch

While Alice and Bob are working on the master branch, Alice wants to develop an
experimental feature.

She creates a branch for this, and works in it:


    %%bash
    
    git branch exp
    git checkout exp
    
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

Bob wants to see Alice's work on the ``exp`` branch. He downloads all branches
of the central repository:


    %%bash
    
    git fetch
    git branch -a

Bob has remote branch ``remotes/central/exp``, but how to work with it?

Adding the **--track** option to the **checkout** command makes Git create a
**tracking branch**:


    %%bash
    git checkout --track origin/exp

A tracking branch is our local copy of a remote branch. Unlike the remote
branch, we have write access to it.

Tracking branches can also be used to call the **pull** and **push** command
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
    
    git graph

We note that:
    - Bob's master branch has 2 more commits than the central one.
    - Bob master branch has 1 more commit that the central one.

The verbose option of **branch** is useful to see tracking branches:


    %%bash
    git branch -avv

Bob pushes the commits of the two branches.


    %%bash
    git push origin exp:exp
    git push origin master:master


    %%bash
    
    git checkout master
    
    git push origin master:master
    git graph

Finally, the ``exp`` branch is merged into master. The merge commit is pushed to
the central repository, and the branch is deleted:


    %%bash
    
    # We already are in the master branch
    
    git merge exp
    git push origin master:master
    git branch -d exp
    git graph

## Distributed workflow          

Committing to a central repository is okay for small teams where developpers
know and trust each other

For larger projects, it is blocking and dangerous to give write access to the
central repository to an external contributor.

Git solves this problem with **forks**.

When a developper wants to contribute to a project, he/she forks the original
bare repository. It means that the developper gets his own bare repository. In
this repository, he develops a feature in a branch. When the work is done, he
asks an administrator to pull the feature branch of his repository to the master
branch of the central repository.

This is called a **pull request**.

Let us see this in practice by adding **Emma** as a developper to our previous
example.


    changedir(workdir)

Emma starts by forking the central repository to her own bare repository.

Note: this is a functionnality provided out of the box by GitHub

Then Emma clones her bare public repository.


    %%bash
    
    git clone --bare central.git central-emma-fork.git
    
    git clone central-emma-fork.git emma


    changedir('emma')

Emma creates a topic branch, works on it, and pushes it to her public
repository:


    %%bash
    
    git branch baz
    git checkout baz
    
    echo "First line" > baz.txt
    git add baz.txt
    git commit -m 'First line in baz.txt'
    
    echo "Second line" >> baz.txt
    git add baz.txt
    git commit -m 'Second line in baz.txt'
    
    git push origin baz:baz


    changedir('alice')

The next step for Emma is to ask Alice to get **baz** branch of **central-emma-
for** pulled into **master** branch for **central**.

Note: GitHub provides functionnality to request a pull, and review the
associated code.

Alice fetches Emma's bare repository. To do this, she first adds Emma's bare
repository to the list of her remote repositories.


    %%bash
    
    git remote add emma file://$HOME/git-training/central-emma-fork.git
    git fetch emma

At this point, Alice and Emmma can interact with each other to add more commits
to the ``baz`` branch. When her work is done, Alice merges it to ``master``, and
``pushes``


    %%bash
    
    git checkout master
    git merge emma/baz
    git push origin master:master

## References

> http://www.git-scm.com/docs

> http://githowto.com

> "Version Control with Git, Powerful tools and techniques for collaborative
software development" By Jon Loeliger, Matthew McCullough
