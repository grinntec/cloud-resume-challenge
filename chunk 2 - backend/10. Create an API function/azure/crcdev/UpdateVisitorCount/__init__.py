import logging
import os
from azure.cosmos import CosmosClient, PartitionKey
import azure.functions as func

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    cosmos_db_endpoint = os.getenv('COSMOS_DB_ENDPOINT')
    cosmos_db_key = os.getenv('COSMOS_DB_KEY')
    database_name = 'VisitorCounter'
    container_name = 'count'

    client = CosmosClient(cosmos_db_endpoint, cosmos_db_key)
    database = client.get_database_client(database_name)
    container = database.get_container_client(container_name)

    # assuming your items have a 'visits' field
    for item in container.query_items(
            query='SELECT * FROM c WHERE c.id = "visitorCount"',
            enable_cross_partition_query=True):
        item['visits'] += 1
        container.upsert_item(item)

    return func.HttpResponse("Visitor count updated.", status_code=200)
