import logging
import azure.functions as func
import hashlib
import uuid
import json


def main(message: func.ServiceBusMessage, signalRMessages: func.Out[str]) -> None:

    # message_content_type = message.content_type
    message_body = message.get_body().decode('utf-8')

    salt = uuid.uuid4().hex
    hashed = hashlib.sha256((message_body + salt).encode('utf-8')).hexdigest()

    logging.info('Python ServiceBus topic trigger processed message.')
    logging.info('Message Body: ' + message_body)
    logging.info('Hashed: ' + hashed)

    signalRMessages.set(json.dumps({
        'target': 'newMessage',
        'arguments': [hashed]
    }))
