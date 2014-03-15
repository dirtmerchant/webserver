#! /bin/bash

echo 'Content-Type: text/html'
echo
echo '<!doctype html>'
echo '<html>'
echo '<head>'
echo '<title>Bash web server</title>'
echo '</head>'
echo '<body>'
echo '<h1>Yes!</h1>'
echo '<h2>The bash webserver works.</h2>'
for i in {1..10}
do  echo '<h1>And you know,I like PYTHON!!!!</h1>'
done
echo "<h3>Your Arguments:</h3>"
echo "<h3>$@</h3>"
echo '</body>'
echo '</html>'
