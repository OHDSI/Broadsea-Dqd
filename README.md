# broadsea-dqd
[under development]

The goal of the Data Quality Dashboard (DQD) project is to design and develop an open-source tool to expose and evaluate observational data quality. This package will run a series of data quality checks against an OMOP CDM instance (currently supports v5.4, v5.3 and v5.2).

First, copy the **sample.env** file to **.env**.

```sh
cp sample.env .env
```

Now you can adjust the credentials of the users in the **.env** file.

Please generate an output folder and set the owner as follows. The results and error of the dashboard will be written there. This has to be done only once.

```sh
mkdir output
sudo chown 999:999 output
```

With the following command you can execute the analysis and after computation a shiny server will represent the results. You can access this server via the port 3838. Please refer to the .env file to adjust parameters if needed.

```sh
docker run --name dqd -p 3838:3838 -v $PWD/output:/tmp/output --env-file .env --rm cr.ukdd.de/pub/ohdsi/dqd:latest
```