
from producer_example import producer_example

service_uri = "my-kafka-service-fras-t-tst.aivencloud.com:12835"
ca_path     = "ca.pem"
cert_path   = "service.cert"
key_path    = "service.key"



def main():
    producer = producer_example(service_uri, ca_path, cert_path, key_path)

if __name__ == '__main__':
    main()