package experiment.mice;

import com.mongodb.client.*;
import com.mongodb.client.model.changestream.ChangeStreamDocument;
import org.bson.Document;
import org.bson.json.JsonMode;
import org.bson.json.JsonWriterSettings;
import org.eclipse.paho.client.mqttv3.MqttClient;
import org.eclipse.paho.client.mqttv3.MqttConnectOptions;
import org.eclipse.paho.client.mqttv3.MqttException;
import org.eclipse.paho.client.mqttv3.MqttMessage;
import org.eclipse.paho.client.mqttv3.persist.MqttDefaultFilePersistence;

import java.io.File;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.swing.*;

public class MongoToMqtt {

    private static final Logger logger = Logger.getLogger(MongoToMqtt.class.getName());
    private static MqttClient mqttclient;
    private static final String BROKER_URL = "ssl://5893ab818d254bdf8af7ef32f0a96df1.s2.eu.hivemq.cloud:8883";
    private static final Map<String, String> MQTT_TOPICS = new HashMap<String, String>() {{
        put("SensoresMovimento", "SensoresMovimento");
        put("SensoresTemperatura", "SensoresTemperatura");
    }};

    private static final String MQTT_USER = "pisid35";
    private static final String MQTT_PASSWORD = "35AhM0@a";
    private static final String[] COLLECTIONS = {"SensoresMovimento", "SensoresTemperatura"};
    private static final String MONGO_ADDRESS = "localhost:27015,localhost:25015,localhost:23015";
    private static final String MONGO_REPLICA = "Sensores";
    private static final String MONGO_DATABASE = "sensores";
    private static final MqttConnectOptions connOpts = new MqttConnectOptions();


    static {
        try {
            connOpts.setUserName(MQTT_USER);
            connOpts.setPassword(MQTT_PASSWORD.toCharArray());
            mqttclient = new MqttClient(BROKER_URL, MqttClient.generateClientId(), new MqttDefaultFilePersistence(System.getProperty("user.dir") + File.separator+ "tmp"));
            mqttclient.connect(connOpts);
        } catch (MqttException e) {
            logger.log(Level.SEVERE, String.format("Error creating client %s", e.getMessage()));
        }
    }

    public static void main(String[] args) {
        // Create the JFrame and JTextArea
        JFrame frame = new JFrame("MQTT Messages");
        JTextArea textArea = new JTextArea(20, 80);
        JScrollPane scrollPane = new JScrollPane(textArea);
        frame.getContentPane().add(scrollPane);

        // Display the JFrame
        frame.pack();
        frame.setLocationRelativeTo(null);
        frame.setVisible(true);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        // Connect to the MongoDB replica set
        MongoClient mongoClient = MongoClients.create("mongodb://" + MONGO_ADDRESS + "/?replicaSet=" + MONGO_REPLICA);
        MongoDatabase database = mongoClient.getDatabase(MONGO_DATABASE);

        // Subscribe to change streams for each MongoDB collection
        for (String collectionName : COLLECTIONS) {
            MongoCollection<Document> collection = database.getCollection(collectionName);
            String mqttTopic = MQTT_TOPICS.get(collectionName);

            ChangeStreamIterable<Document> changeStreamIterable = collection.watch();
            MongoCursor<ChangeStreamDocument<Document>> cursor = changeStreamIterable.iterator();
            while (cursor.hasNext()) {
                ChangeStreamDocument<Document> changeStreamDocument = cursor.next();
                Document document = changeStreamDocument.getFullDocument();
                document.remove("_id");  // remove the _id field
                JsonWriterSettings settings = JsonWriterSettings.builder().outputMode(JsonMode.RELAXED).build();
                String json = document.toJson(settings);

                // Publish the JSON message to the HiveMQ broker
                MqttMessage message = new MqttMessage(json.getBytes());
                message.setQos(mqttTopic.equals("sensoresMovimentoData") ? 1 : 0); // set the QoS based on the topic
                try {
                    mqttclient.publish(mqttTopic, message);
                    textArea.append("Published MQTT message to " + mqttTopic + ": " + json + "\n");
                } catch (MqttException e) {
                    logger.warning("Failed to publish MQTT message: " + e.getMessage());
                }
            }
        }
    }
}