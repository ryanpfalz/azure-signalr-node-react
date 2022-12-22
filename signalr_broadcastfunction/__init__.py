import logging
import azure.functions as func
import hashlib
import uuid
import json


def main(message: func.HttpRequest, signalRMessages: func.Out[str]) -> func.HttpResponse:

    message_body = message.get_body().decode('utf-8')

    salt = uuid.uuid4().hex
    hashed = hashlib.sha256((message_body + salt).encode('utf-8')).hexdigest()

    logging.info('Message Body: ' + message_body)
    logging.info('Hashed: ' + hashed)
    logging.info('Salt: ' + salt)

    signalRMessages.set(json.dumps({
        'target': 'newMessage',
        'arguments': [salt, hashed]
    }))

    return func.HttpResponse(json.dumps({'message': 'Done'}))
