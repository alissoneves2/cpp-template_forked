
while true
do
  echo "Starting Jenkins agent..."
  java -jar agent.jar \
    -url http://localhost:8080/ \
    -secret 4153a51fa26385d6d040614c1b7b6f50b897a9e941750fdf1c61bf057ac9cbb3 \
    -name "cpp-agent" \
    -webSocket \
    -workDir "/home/alissoneves/agent"

  echo "Agent disconnected. Restarting in 5 seconds..."
  sleep 5
done