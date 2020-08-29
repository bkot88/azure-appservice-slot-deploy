
import logging
import requests
import time

logging.basicConfig(format='%(levelname)s %(asctime)s: %(message)s', level=logging.INFO, datefmt='%H:%M:%S')

def call_prod():
    result = requests.get("https://webapp-healthcheck-dev.azurewebsites.net/")
    
    json_result = None
    try:
        json_result = result.json()
    except Exception:
        pass
    
    logging.info(f'{result.status_code} - {json_result}')

if __name__ == "__main__":
    while True:
        try:
            call_prod()
            time.sleep(0.1)
        except Exception as ex:
            logging.error(ex)
