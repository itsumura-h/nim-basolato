ducere build -p:5000,5001,5002,5003
while [ 1 ]; do
  ./main5000 & \
  ./main5001 & \
  ./main5002 & \
  ./main5003
done
