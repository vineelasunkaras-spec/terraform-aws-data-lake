"""Glue job: read raw catalog tables, standardize, write partitioned Parquet to the curated zone."""
import sys

from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from pyspark.sql import functions as F

args = getResolvedOptions(sys.argv, ["JOB_NAME", "SOURCE_DB", "TARGET_PATH"])
glue = GlueContext(SparkContext.getOrCreate())
spark = glue.spark_session
job = Job(glue)
job.init(args["JOB_NAME"], args)

for t in spark.catalog.listTables(args["SOURCE_DB"]):
    dyf = glue.create_dynamic_frame.from_catalog(
        database=args["SOURCE_DB"], table_name=t.name, transformation_ctx=f"src_{t.name}"
    )
    if dyf.count() == 0:
        continue
    df = dyf.toDF()
    df = df.toDF(*[c.strip().lower().replace(" ", "_") for c in df.columns])
    df = df.dropDuplicates().withColumn("load_date", F.current_date())
    df.write.mode("append").partitionBy("load_date").parquet(f"{args['TARGET_PATH']}{t.name}/")

job.commit()
