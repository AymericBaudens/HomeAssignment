
from producer_example import producer_example

service_uri = "my-kafka-service-aymeric-e560.aivencloud.com:24842"
ca_path     = "ca.pem"
cert_path   = "service.cert"
key_path    = "service.key"



def main():
    producer = producer_example(service_uri, ca_path, cert_path, key_path)

if __name__ == '__main__':
    main()