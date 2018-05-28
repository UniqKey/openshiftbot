IMAGE=$1
TAG=$(date +"%Y-%m-%d_%H-%M-%S")
echo promoting $IMAGE using tag $TAG
./oc tag $PROMOTE_PROJECT_FROM/$IMAGE:latest $PROMOTE_PROJECT_FROM/$IMAGE:$TAG
./oc tag $PROMOTE_PROJECT_FROM/$IMAGE:$TAG $PROMOTE_PROJECT_TO/$IMAGE:latest
./oc get dc $IMAGE