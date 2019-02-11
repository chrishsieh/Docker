set -x

download_crm() {
    local crmlatest;
    if [ "${CRM_RELEASE_VERSION}" == "latest" ]; then
        crmlatest=$(curl -s https://api.github.com/repos/churchCRM/CRM/releases/latest | grep "browser_download_url.*zip" | cut -d '"' -f 4);
    else
        crmlatest="https://github.com/ChurchCRM/CRM/releases/download/${CRM_RELEASE_VERSION}/ChurchCRM-${CRM_RELEASE_VERSION}.zip";
    fi
    cd /var/www/default \
    && rm -rf *.zip \
    && wget $crmlatest \
    && unzip -q -o *.zip \
    && rm -f /var/www/default/churchcrm/Include/Config.php
}

if ! [ -d /var/www/default/churchcrm/ ]; then
    download_crm;
fi

if ! [ -f /var/www/default/churchcrm/index.php ]; then
    download_crm;
fi

if ! [ -f /var/www/default/churchcrm/Include/Config.php ]; then
    cp /var/www/default/churchcrm/Include/Config.php.example /var/www/default/churchcrm/Include/Config.php
    chmod 777 /var/www/default/churchcrm/Include/Config.php

    # Create ChurchCRM Config File
    sed -i "s/||DB_SERVER_NAME||/mysql/g" /var/www/default/churchcrm/Include/Config.php
    sed -i "s/||DB_SERVER_PORT||/3306/g" /var/www/default/churchcrm/Include/Config.php
    sed -i "s/||DB_NAME||/$MYSQL_USER_DB/g" /var/www/default/churchcrm/Include/Config.php
    sed -i "s/||DB_USER||/$MYSQL_USER/g" /var/www/default/churchcrm/Include/Config.php
    sed -i "s/||DB_PASSWORD||/$MYSQL_USER_PWD/g" /var/www/default/churchcrm/Include/Config.php
    sed -i "s/||URL||//g" /var/www/default/churchcrm/Include/Config.php
    sed -i "s/||ROOT_PATH||//g" /var/www/default/churchcrm/Include/Config.php
fi

/docker-entrypoint.sh