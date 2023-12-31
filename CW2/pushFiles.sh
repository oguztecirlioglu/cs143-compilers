cp cool.y pa2-grading.pl ~/cw2
echo "*** Files pushed successfully."

cd ~/cw2
make parser
echo "*** Recompiled parser successfully."

echo "*** Running grading script:"
perl pa2-grading.pl
