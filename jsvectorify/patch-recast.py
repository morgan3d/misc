# Apply patch for the ... operator in objects by Jamby93. Patch script
# by Morgan

import re

# The source location we're looking for. This much context is needed
# to make it unambiguous
src = """else if (this.match('*')) {
this.nextToken();
}
else {
computed = this.match('[');
key = this.parseObjectPropertyKey();
}"""

# Replace that middle else with the extra case
dst = src.replace('else {', """else if (this.match('...')) { return this.parseSpreadElement(); } else {""");

# Convert src to regexp
src = src.replace('*', '\\*').replace('\n', '\\s+').replace('.', '\\.').replace('[', '\\[').replace(']', '\\]').replace('(', '\\(').replace(')', '\\)')

# Load the file
file = open('tmp/src/recast.js', 'r')
text = file.read()
file.close()

# Replace
text = re.sub(src, dst, text)

# Save in place
file = open('tmp/src/recast.js', 'w')
file.write(text)
file.close()
