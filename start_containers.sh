if [ "$(uname)" = "Linux" ]
then
	xhost + local:root
	DISPLAY="unix:0"
else
open -a Xquartz
xhost + 127.0.0.1
DISPLAY="host.docker.internal:0"
fi
docker-compose up