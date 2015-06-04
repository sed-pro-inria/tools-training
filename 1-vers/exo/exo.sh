git init

# First commit
cat > main.py << EOF
#!/usr/bin/env python

def greet():
    print("Hello world!")

greet()
EOF
git add main.py
git commit -m 'Add greet function'

# Second commit
cat > main.py << EOF
#!/usr/bin/env python

def greet(name):
    print("Hello %s!" % name)

greet("Alice")
EOF
git add main.py
git commit -m 'Add <name> argument to greet function'

# Third commit
cat > main.py << EOF
#!/usr/bin/env python
import sys

def greet(name):
    print("Hello %s!" % name)

if len(sys.argv) > 1:
    greet(sys.argv[1])
else:
    sys.stderr.write("Usage: %s NAME\n" % sys.argv[0])
    sys.exit(1)
EOF
git add main.py
git commit -m 'Read <name> on command line'

# format_name branch
git checkout -b format_name
cat > main.py << EOF
#!/usr/bin/env python
import sys

def greet(name):
    print("Hello %s!" % name.capitalize())

if len(sys.argv) > 1:
    greet(sys.argv[1])
else:
    sys.stderr.write("Usage: %s NAME\n" % sys.argv[0])
    sys.exit(1)
EOF
git add main.py
git commit -m 'Capitalize <name>'

# master
git checkout master
cat > main.py << EOF
#!/usr/bin/env python
import sys

def greet(name):
    print("Hello %s! How are you?" % name)

if len(sys.argv) > 1:
    greet(sys.argv[1])
else:
    sys.stderr.write("Usage: %s NAME\n" % sys.argv[0])
    sys.exit(1)
EOF
git add main.py
git commit -m 'More verbose greeting'

# merge
git merge format_name
git checkout -b format_name
cat > main.py << EOF
#!/usr/bin/env python
import sys

def greet(name):
    print("Hello %s! How are you?" % name.capitalize())

if len(sys.argv) > 1:
    greet(sys.argv[1])
else:
    sys.stderr.write("Usage: %s NAME\n" % sys.argv[0])
    sys.exit(1)
EOF
git add main.py
git commit -m 'Merge format_name branch'
