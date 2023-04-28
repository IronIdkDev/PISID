package experiment.mice;

import com.mongodb.client.MongoCollection;
import org.bson.Document;
import org.eclipse.paho.client.mqttv3.MqttClient;
import org.eclipse.paho.client.mqttv3.MqttException;
import org.eclipse.paho.client.mqttv3.MqttMessage;
import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence;

import java.util.logging.Level;
import java.util.logging.Logger;

public class MongoToMqtt {

    // MongoDB replica set URI
    private static final String MONGO_URI = "mongodb://localhost:27015/?replicaSet=Sensores&readPreference=primary&ssl=false";

    // MQTT broker URL
    private static final String BROKER_URL = "tcp://localhost:1883";

    // MQTT topic to publish data to
    private static final String MQTT_TOPIC = "replicaset-data";

    // MongoDB database name
    private static final String DB_NAME = "sensores";

    // MongoDB collections to read data from
    private static final String[] COLLECTIONS = {"Outliers", "SensoresMovimento", "SensoresTemperatura"};

    public static void main(String[] args) {
        try (com.mongodb.client.MongoClient mongoClient = com.mongodb.client.MongoClients.create(MONGO_URI);
             MqttClient mqttClient = createMqttClient()) {

            for (String collectionName : COLLECTIONS) {
                MongoCollection<Document> collection = mongoClient.getDatabase(DB_NAME).getCollection(collectionName);
                publishDocumentsToMqtt(collection, mqttClient);
            }

        } catch (Exception e) {
            Logger.getLogger(MongoToMqtt.class.getName()).log(Level.SEVERE, null, e);
        }
    }

    private static MqttClient createMqttClient() throws MqttException {
        MqttClient mqttClient = new MqttClient(BROKER_URL, MqttClient.generateClientId(), new MemoryPersistence());
        mqttClient.connect();
        return mqttClient;
    }

    private static void publishDocumentsToMqtt(MongoCollection<Document> collection, MqttClient mqttClient) {
        for (Document document : collection.find()) {
            publishDocumentToMqtt(document, mqttClient);
        }
    }

    private static void publishDocumentToMqtt(Document document, MqttClient mqttClient) {
        try {
            String payload = document.toJson();
            MqttMessage message = new MqttMessage(payload.getBytes());
            mqttClient.publish(MQTT_TOPIC, message);
        } catch (MqttException e) {
            Logger.getLogger(MongoToMqtt.class.getName()).log(Level.SEVERE, null, e);
        }
    }
}