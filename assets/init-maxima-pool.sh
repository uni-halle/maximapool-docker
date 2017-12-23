#!/usr/bin/env bash

echo "###############################################"
echo "# Maxima pool starting up                     #"
echo "# Remember never to expose this service       #"
echo "# to unauthenticated parties.                 #"
echo "###############################################"

if [ "$1" = 'catalina.sh' ]; then
      if [ "$MAXIMAPOOL_ADMIN_PASSWORD" = "" ] || [ "$MAXIMAPOOL_ADMIN_PASSWORD" = "TODO!_FIXME!_CHANGE_ME!" ]; then
            echo "Please change MAXIMAPOOL_ADMIN_PASSWORD."
            echo "You may do so by running:"
            echo "docker run -e \"MAXIMAPOOL_ADMIN_PASSWORD=good_secret_passwd\""
            echo "Or use an .env file which defines that variable. Exiting."
            exit
      fi

      if [ ! -f ${MAXIMAPOOL}/pool.conf ]; then
            echo "Missing ${MAXIMAPOOL}/pool.conf"
            echo "Please edit volumes/pool.conf.template"
            echo "and mount that or a copy of it to"
            echo "${MAXIMAPOOL}/pool.conf"
      fi

      echo "Rebuilding web archive ..."
      rm -rf $TOMCAT/webapps/MaximaPool.war MaximaPool.war
      cd ${MAXIMAPOOL}/
      # servlet.conf.template contains a password that must be
      # updated from the environment
      envsubst < servlet.conf.template > servlet.conf
      ant
      mv MaximaPool.war $TOMCAT/webapps/MaximaPool.war

      echo "Setting permission for $RUN_USER:$RUN_GROUP"
      chown -R root:root                       ${CATALINA_HOME}/                   \
          && chmod -R 775                      ${CATALINA_HOME}/                   \
          && chmod    g+s                      ${CATALINA_HOME}/                   \
          && chmod -R 700                      ${CATALINA_HOME}/temp               \
          && chmod -R 750                      ${CATALINA_HOME}/logs               \
          && chmod -R 770                      ${CATALINA_HOME}/work               \
          && find  ${CATALINA_HOME}/conf/. -type f -exec chmod 400 {} +            \
          && find  ${CATALINA_HOME}/conf/. -type d -exec chmod 500 {} +            \
          && chown -R ${RUN_USER}:${RUN_GROUP} ${CATALINA_HOME}/work               \
          && chown -R ${RUN_USER}:${RUN_GROUP} ${CATALINA_HOME}/temp               \
          && chown -R ${RUN_USER}:${RUN_GROUP} ${CATALINA_HOME}/webapps            \
          && chown -R ${RUN_USER}:${RUN_GROUP} ${CATALINA_HOME}/conf               \
          && chown -R ${RUN_USER}:${RUN_GROUP} ${CATALINA_HOME}/logs

      touch ${CATALINA_HOME}/logs/catalina.out

      if  [ -n "$(ls -A ${CATALINA_HOME}/logs)" ]; then
          echo "Fixing logs permission"
          chown -R   ${RUN_USER}:${RUN_GROUP}  ${CATALINA_HOME}/logs
          chmod      640                       ${CATALINA_HOME}/logs/*
      fi
      exec gosu "${RUN_USER}:${RUN_GROUP}" "$@"
fi
exec "$@"

