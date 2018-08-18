BUILD_COMMIT=$(curl http://metadata.google.internal/computeMetadata/v1/project/attributes/backend_build_commit -H "Metadata-Flavor: Google")
sudo chmod -R 777 /var/app/lenken_api
cd /var/app/lenken_api
sudo mkdir -p ~/.ssh
sudo cp /etc/.ssh/id_rsa ~/.ssh && sudo chmod 400 ~/.ssh/id_rsa
git pull origin develop
git checkout ${BUILD_COMMIT}
sudo touch .env && chmod 777 .env
sudo curl http://metadata.google.internal/computeMetadata/v1/project/attributes/lenken_backend_env -H "Metadata-Flavor: Google" > .env
sudo composer install --no-suggest
cd public && sudo php -S 127.0.0.1:3000