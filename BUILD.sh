VERSION=$(curl -s -XGET https://api.github.com/repos/RainLoop/rainloop-webmail/tags | grep name -m 1 | awk '{print $2}' | cut -d'"' -f2)

docker buildx build --platform linux/amd64,linux/arm64 \
-f Dockerfile \
-t newargus/rainloop-webmail:latest \
-t newargus/rainloop-webmail:"${VERSION}" \
--build-arg TAG_VERSION="${VERSION}" \
--cpu-quota="400000" \
--memory=16g \
--push .
