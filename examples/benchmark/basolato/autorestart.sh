while [ 1 ]; do
  nim c -r -d:relese --gc:arc --putenv:port=5000 main
done

# while [ 1 ]; do
#   nim c -r -d:relese --gc:arc --putenv:port=5000 --threads:on --threadAnalysis:off main
# done
