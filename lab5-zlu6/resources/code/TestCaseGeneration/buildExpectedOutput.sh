rm -f tests/*/*.out
for f in tests/*/*.bin
do
echo "Running $f"
./runTest.sh 0 0 Solution/lab* $f >> ${f%.bin}.out
done