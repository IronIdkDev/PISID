package experiment.mice;

import com.mongodb.client.*;
import com.mongodb.client.model.changestream.ChangeStreamDocument;
import org.bson.Document;
import org.bson.json.JsonMode;
import org.bson.json.JsonWriterSettings;
import org.eclipse.paho.client.mqttv3.*;
import org.eclipse.paho.client.mqttv3.persist.MqttDefaultFilePersistence;

import javax.swing.*;
import java.awt.*;
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

    private static String lastMovMessage = null;
    private static String lastTempMessage = null;
    private static long lastSentTime = 0;

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

    public static void main(String[] args) throws MqttException {

        final boolean[] running = {true};

        // Set Look and Feel to make the UI look more modern
        try {
            UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
        } catch (ClassNotFoundException | InstantiationException | IllegalAccessException | UnsupportedLookAndFeelException e) {
            logger.log(Level.SEVERE, "Error setting the look and feel", e);
        }

        JFrame frame = new JFrame("MQTT Messages");
        JTextArea textArea = new JTextArea(20, 80);
        JScrollPane scrollPane = new JScrollPane(textArea);
        JButton button = new JButton(running[0] ? "Stop" : "Start");
        frame.getContentPane().add(scrollPane);
        frame.setSize(500, 500);
        frame.setLayout(new BorderLayout());
        frame.add(scrollPane, BorderLayout.CENTER);
        frame.add(button, BorderLayout.SOUTH);

        // Display the JFrame
        frame.pack();
        frame.setLocationRelativeTo(null);
        frame.setVisible(true);
        frame.setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);

        button.addActionListener(e -> {
            running[0] = !running[0];
            button.setText(running[0] ? "Stop" : "Start");
        });

        // Connect to the MongoDB replica set
        MongoClient mongoClient = MongoClients.create("mongodb://" + MONGO_ADDRESS + "/?replicaSet=" + MONGO_REPLICA);
        MongoDatabase database = mongoClient.getDatabase(MONGO_DATABASE);

        // Watch for changes in the MongoDB collections
        MongoCollection<Document> movCollection = database.getCollection(MONGOCOLLECTIONMOV);
        MongoCollection<Document> tempCollection = database.getCollection(MONGOCOLLECTIONTEMP);

        Thread movThread = new Thread(() -> {
            MongoCursor<ChangeStreamDocument<Document>> cursor = movCollection.watch().iterator();
            while (running[0]) {
                if (cursor.hasNext()) {
                    try {
                        processMovementData(textArea, cursor);
                    } catch (MqttException e) {
                        logger.log(Level.SEVERE, String.format("Error publishing message: %s", e.getMessage()));
                    }
                }
                // sleep for 10 milliseconds to prevent CPU hogging
                try {
                    Thread.sleep(10);
                } catch (InterruptedException e) {
                    throw new RuntimeException(e);
                }
            }
            cursor.close();
        });

        Thread tempThread = new Thread(() -> {
            MongoCursor<ChangeStreamDocument<Document>> cursor = tempCollection.watch().iterator();
            while (running[0]) {
                if (cursor.hasNext()) {
                    try {
                        processTemperatureData(textArea, cursor);
                    } catch (MqttException e) {
                        logger.log(Level.SEVERE, String.format("Error publishing message: %s", e.getMessage()));
                    }
                }
                // sleep for 10 milliseconds to prevent CPU hogging
                try {
                    Thread.sleep(10);
                } catch (InterruptedException e) {
                    throw new RuntimeException(e);
                }
            }
            cursor.close();
        });

        movThread.start();
        tempThread.start();
    }

    private static void processTemperatureData(JTextArea textArea, MongoCursor<ChangeStreamDocument<Document>> tempCursor) throws MqttException {
        ChangeStreamDocument<Document> changeStreamDocument = tempCursor.next();
        Document document = changeStreamDocument.getFullDocument();
        if (document == null) {
            return;
        }
        document.remove("_id");
        String json = document.toJson(JsonWriterSettings.builder().outputMode(JsonMode.RELAXED).build());

        // Publish each document as a separate MQTT message to the HiveMQ broker
        String[] lines = json.split("\\r?\\n");
        for (String line : lines) {
            if (line.equals(lastTempMessage)) {
                continue;
            }
            MqttMessage mqttMessage = new MqttMessage(line.getBytes());
            mqttMessage.setQos(1);
            mqttclient.publish(mqttTopicTemp, mqttMessage);
            textArea.append(mqttTopicTemp + ": " + line + "\n");
            lastTempMessage = line;
        }
    }

    private static void processMovementData(JTextArea textArea, MongoCursor<ChangeStreamDocument<Document>> movCursor) throws MqttException {
        ChangeStreamDocument<Document> changeStreamDocument = movCursor.next();
        Document document = changeStreamDocument.getFullDocument();

        if (document == null) {
            return;
        }

        document.remove("_id");

        JsonWriterSettings settings = JsonWriterSettings.builder()
                .outputMode(JsonMode.RELAXED)
                .build();

        String json = document.toJson(settings);
        String[] lines = json.split("\\r?\\n");

        for (String line : lines) {
            if (line.equals(lastMovMessage)) {
                continue;
            }

            MqttMessage mqttMessage = new MqttMessage(line.getBytes());
            mqttMessage.setQos(1);
            mqttclient.publish(mqttTopicMov, mqttMessage);

            textArea.append(mqttTopicMov + ": " + line + "\n");
            lastMovMessage = line;
        }
    }
}