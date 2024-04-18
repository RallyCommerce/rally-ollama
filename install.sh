#!/bin/bash

cat << 'EOF' > /usr/local/bin/rally-ollama
#!/bin/bash

container_name="open-webui"

install_ui(){
  if ! command -v brew &> /dev/null
  then
      echo "Docker is not installed. Install it by navigating to https://docs.docker.com/get-docker/ and following the instructions for your platform."
      exit 1
  fi

  if ! command -v brew &> /dev/null
  then
      echo "Homebrew is not installed. Install it by executing '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"' in your terminal."
      exit 1
  fi

  if [ "$( docker container inspect -f '{{.State.Running}}' $container_name )" != "true" ]; then
    docker run -d -p 3030:8080 --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data --name $container_name --restart always ghcr.io/open-webui/open-webui:main
  fi
}

start_ollama() {
  nohup ollama serve &> /dev/null
}

start_ui() {
  if [ "$( docker container inspect -f '{{.State.Running}}' $container_name )" != "true" ]; then
    docker start $container_name
  fi

  echo "Opening web UI..."
  sleep 5
  open http://localhost:3030/
}

stop_ui() {
  echo "Stopping web UI..."
  docker stop $container_name
}

install_ollama(){
  if command -v ollama &> /dev/null
  then
      echo "Ollama already installed."
  else
      brew install ollama
  fi
}

case $1 in
  install)
    install_ollama
    install_ui
  ;;
  start)
    start_ollama
    start_ui
  ;;
  stop)
    stop_ui
  ;;
    *)
    # pass to ollama native cli as wrapper
    ollama "$@"
    ;;
esac
EOF

chmod +x /usr/local/bin/rally-ollama

echo "rally-ollama has been installed successfully and is now executable from anywhere."
