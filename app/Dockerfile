FROM alpine:latest

RUN apk update \
    && apk upgrade \
    && apk add --no-cache py3-pip python3

WORKDIR /app
COPY ./*.py ./requirements.txt /app/
RUN pip install -r requirements.txt

ENTRYPOINT [ "python3" ]
CMD [ "app.py" ]
