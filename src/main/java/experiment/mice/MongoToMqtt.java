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

import javax.swing.*;
import java.io.File;
import java.util.logging.Level;
import java.util.logging.Logger;

public class MongoToMqtt {

    private static final Logger logger = Logger.getLogger(MongoToMqtt.class.getName());
    private static MqttClient mqttclient;
    private static final String BROKER_URL = "ssl://5893ab818d254bdf8af7ef32f0a96df1.s2.eu.hivemq.cloud:8883";
    private static String mqttTopicMov = "sensoresMov";
    private static String mqttTopicTemp = "sensoresTemp";

    private static final String MQTT_USER = "pisid35";
    private static final String MQTT_PASSWORD = "35AhM0@a";
    private static final String MONGOCOLLECTIONMOV = "SensoresMovimento";
    private static final String MONGOCOLLECTIONTEMP = "SensoresTemperatura";
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

        boolean result = true;

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

        while (result) {
            MongoCollection<Document> movCollection = database.getCollection(MONGOCOLLECTIONMOV);
            mqttTopicMov = MONGOCOLLECTIONMOV;

            MongoCollection<Document> tempCollection = database.getCollection(MONGOCOLLECTIONTEMP);
            mqttTopicTemp = MONGOCOLLECTIONTEMP;

            ChangeStreamIterable<Document> movChangeStreamIterable = movCollection.watch();
            ChangeStreamIterable<Document> tempChangeStreamIterable = tempCollection.watch();

            MongoCursor<ChangeStreamDocument<Document>> movCursor = movChangeStreamIterable.iterator();
            MongoCursor<ChangeStreamDocument<Document>> tempCursor = tempChangeStreamIterable.iterator();

            while (movCursor.hasNext() || tempCursor.hasNext()) {
                if (movCursor.hasNext()) {
                    System.out.println("entrou 1 if");
                    ChangeStreamDocument<Document> changeStreamDocument = movCursor.next();
                    Document document = changeStreamDocument.getFullDocument();
                    document.remove("_id");  // remove the _id field
                    JsonWriterSettings settings = JsonWriterSettings.builder().outputMode(JsonMode.RELAXED).build();
                    String json = document.toJson(settings);

                    // Publish the JSON message to the HiveMQ broker
                    MqttMessage message = new MqttMessage(json.getBytes());
                    message.setQos(1);
                    try {
                        mqttclient.publish(mqttTopicMov, message);
                        textArea.append("Published MQTT message to " + mqttTopicMov + ": " + json + "\n");
                    } catch (MqttException e) {
                        logger.warning("Failed to publish MQTT message: " + e.getMessage());
                    }
                }
                if (tempCursor.hasNext()) {
                    System.out.println("2");
                    ChangeStreamDocument<Document> changeStreamDocument = tempCursor.next();
                    Document document = changeStreamDocument.getFullDocument();
                    document.remove("_id");  // remove the _id field
                    JsonWriterSettings settings = JsonWriterSettings.builder().outputMode(JsonMode.RELAXED).build();
                    String json = document.toJson(settings);

                    // Publish the JSON message to the HiveMQ broker
                    MqttMessage message = new MqttMessage(json.getBytes());
                    message.setQos(0);
                    try {
                        mqttclient.publish(mqttTopicTemp, message);
                        textArea.append("Published MQTT message to " + mqttTopicTemp + ": " + json + "\n");
                    } catch (MqttException e) {
                        logger.warning("Failed to publish MQTT message: " + e.getMessage());
                    }
                }
                movCursor = movCollection.watch().iterator();
                tempCursor = tempCollection.watch().iterator();
            }
        }
    }
}