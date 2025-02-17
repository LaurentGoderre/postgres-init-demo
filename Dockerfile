FROM ruby AS data

WORKDIR /data/

ADD https://raw.githubusercontent.com/lorint/AdventureWorks-for-Postgres/refs/heads/master/update_csvs.rb .

RUN set -ex; \
    curl -O -sSL https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks-oltp-install-script.zip; \
    unzip AdventureWorks-oltp-install-script.zip; \
    rm AdventureWorks-oltp-install-script.zip; \
    ruby update_csvs.rb

#---

FROM postgres:17 AS db

WORKDIR /data/

COPY --from=data /data/*.csv /data
ADD --chmod=777  https://raw.githubusercontent.com/lorint/AdventureWorks-for-Postgres/refs/heads/master/install.sql /docker-entrypoint-initdb.d/

ENV POSTGRES_DB Adventureworks
ENV POSTGRES_PASSWORD=1234

RUN docker-ensure-initdb.sh

#---

FROM busybox

COPY --from=db --chown=70:70 /var/lib/postgresql/data /in/

CMD ["sh", "-c", "cp -rp /in/* /db-data && chmod 0750 /db-data"]
