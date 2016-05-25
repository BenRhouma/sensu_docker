
## Sensu docker image: 

#### Run : 
sudo docker run -d -p 6379:6379 -p 15672:15672 -p 5672:5672 -p 4567:4567 -p 3000:3000 zbenrhouma/sensu


#### Architecture components: 
- Sensu Server 
- Sensu API
- RabbitMQ server
- Redis Server 
- Uchiwa dashboard

![alt Sensu Docker image architecture](https://i.imgur.com/3nCh9si.png "Sensu Docker image architecture")



