…or create a new repository on the command line

```
echo "# Test" >> README.md
git init
git add README.md
git commit -m "first commit"
git remote add origin https://github.com/kunSong/Test.git
git push -u origin master
```

…or push an existing repository from the command line

```
git remote add origin https://github.com/kunSong/Test.git
git push -u origin master
```

…or import code from another repository
You can initialize this repository with code from a Subversion, Mercurial, or TFS project.

```
git init
git remote add origin https://github.com/kunSong/Test.git
git pull origin master
git status ./
git add
git commit
git push -u origin master
git commit -amend
git push -u -f origin master

git fetch origin master:songkun-xxxx
git checkout songkun-xxxx
git commit
git push origin HEAD:master
git commit -amend
git push origin HEAD:master
```

```
cd .repo/manifest
ls
croot
repo init -b gingerbread-release 
repo sync (not needed if your local copy is up to date)
repo start gingerbread-release --all 
repo branches
```
