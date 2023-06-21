
from kafka import KafkaProducer
from datetime import datetime
import json
import uuid

def producer_example(service_uri, ca_path, cert_path, key_path):
    producer = KafkaProducer(
        bootstrap_servers=service_uri,
        security_protocol="SSL",
        ssl_cafile=ca_path,
        ssl_certfile=cert_path,
        ssl_keyfile=key_path,
    )

    for i in range(1, 5):
        message = {
                "sensor_type" : "thermometer",
                "sensor_id": "1234",
                "unit": "celsius degree",
                "value" : i,
                "timestamp": str(datetime.now().isoformat())
            }

        print("Sending: {}".format(message))

        producer.send("mytopic",
                      json.dumps(message).encode("utf-8"),
                      json.dumps({'id': str(uuid.uuid4())}).encode('utf-8')
                      )

    # Wait for all messages to be sent
    producer.flush()