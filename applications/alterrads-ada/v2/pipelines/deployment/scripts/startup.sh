#!/bin/bash
set -e

# 1. Clone repository
git clone ${GITHUB_REPOSITORY_URL} && \
# 2. Move to working directory
cd ${WORKING_DIRECTORY} && \
# 3. Switch to working branch
git checkout -b ${BRANCH_NAME} && \
# 4. Package/Zip application source code
zip -r app.zip . -x '.*' && \
# 5. Upload package to storage account
az storage blob upload -f app.zip -c ${CONTAINER_NAME} -n ${APP_SERVICE_NAME}_$(date '+%Y%m%d%H%M%S').zip && \
# 6. Deploy application to app service
az webapp deploy --name ${APP_SERVICE_NAME} --resource-group ${RESOURCE_GROUP_NAME} --src-path app.zip