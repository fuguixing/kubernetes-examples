FROM shortesttrack/iss-async:kafka
ADD user_script.ipynb /home/root/
ADD conf /home/root/
#RUN pip install st-dataprovider
ENV KAFKA_ADR 172.17.0.1:9092
ENV KAFKA_TOPIC topic
EXPOSE 8000