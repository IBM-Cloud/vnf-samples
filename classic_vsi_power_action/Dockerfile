FROM python:3.8.3-alpine
COPY . /app
WORKDIR /app
RUN pip install --upgrade -r requirements.txt
CMD python ./vsi_power_action.py
