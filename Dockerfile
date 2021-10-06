FROM python:3.7.3-stretch

WORKDIR /app

COPY pyapp/. /app/

RUN pip install --no-cache-dir pip==21.2.4 && \
pip install --no-cache-dir -r requirements.txt

EXPOSE 80

CMD ["python", "app.py"]
