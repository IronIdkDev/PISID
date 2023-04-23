package experiment.example;

import com.mongodb.*;
import com.mongodb.util.JSON;
import com.mongodb.util.JSONParseException;
import org.eclipse.paho.client.mqttv3.*;

import javax.swing.*;
import java.awt.*;
import java.util.Random;
import java.util.logging.Logger;
import java.util.logging.Level;


public class ReadFromMQTTToMongoDB implements MqttCallback{
    private static final Logger logger = Logger.getLogger(ReadFromMQTTToMongoDB.class.getName());

    private DBCollection mongocolmov;
    private DBCollection mongocoltemp;
    private DBCollection mongocolout;
    private static String mongoUser = "root";
    private static String mongoPassword = "testesenha";
    private static String mongoAddress = "localhost:27015,localhost:25015,localhost:23015";
    private static String mongoReplica = "Sensores";
    private static String mongoDatabase = "sensores";
    private static String cloudTopicMov = "pisid_mazemov";
    private static String cloudTopicTemp = "pisid_mazetemp";
    private static String mongoAuthentication = "false";
    private static final String mongoCollectionMov = "SensoresMovimento";
    private static final String mongoCollectionTemp = "SensoresTemperatura";
    private static final String mongoCollectionOut = "Outliers";

    private final JTextArea documentLabel;

    private ReadFromMQTTToMongoDB() {
        documentLabel = new JTextArea("\n");
    }

    private void createWindow() {
        JFrame frame = new JFrame("Cloud to Mongo");
        frame.setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);

        JLabel label = new JLabel("Data from broker: ", SwingConstants.CENTER);
        label.setPreferredSize(new Dimension(600, 30));

        JScrollPane scrollPane = new JScrollPane(documentLabel, ScrollPaneConstants.VERTICAL_SCROLLBAR_ALWAYS, ScrollPaneConstants.HORIZONTAL_SCROLLBAR_ALWAYS);
        scrollPane.setPreferredSize(new Dimension(600, 200));

        JButton button = new JButton("Stop the program");
        button.addActionListener(e -> System.exit(0));

        frame.getContentPane().add(label, BorderLayout.NORTH);
        frame.getContentPane().add(scrollPane, BorderLayout.CENTER);
        frame.getContentPane().add(button, BorderLayout.SOUTH);

        frame.setLocationRelativeTo(null);
        frame.pack();
        frame.setVisible(true);
    }

    public static void main(String[] args) throws MqttException {
        String cloudServer = "tcp://broker.mqtt-dashboard.com:1883";
        String localServer = "tcp://localhost:1883";
        ReadFromMQTTToMongoDB cloudToMongo = new ReadFromMQTTToMongoDB();
        cloudToMongo.createWindow();
        cloudToMongo.connectToMqttServer(localServer, cloudTopicMov, cloudTopicTemp);
        cloudToMongo.connectMongo();
    }

    /**
     * Connects to an MQTT server and subscribes to the specified topics.
     *
     * @param cloudServer the URL of the MQTT server to connect to
     * @param cloudTopicMov the topic to subscribe to for movement data
     * @param cloudTopicTemp the topic to subscribe to for temperature data
     * @throws MqttException if there is an error connecting to the MQTT server or subscribing to topics
     */
    private void connectToMqttServer(String cloudServer, String cloudTopicMov, String cloudTopicTemp) throws MqttException {
        final String CLIENT_ID_PREFIX = "CloudToMongo_";
        int clientId = (new Random()).nextInt(100000);

        try (MqttClient mqttClient = new MqttClient(cloudServer, CLIENT_ID_PREFIX + clientId + "_" + cloudTopicMov)) {
            mqttClient.connect();
            mqttClient.setCallback(this);
            try {
                mqttClient.subscribe(cloudTopicMov);
                mqttClient.subscribe(cloudTopicTemp);
            } catch (MqttException e) {
                logger.log(Level.SEVERE, "Error subscribing to topics: " + e.getMessage());
            }
        } catch (MqttException e) {
            logger.log(Level.WARNING, "Error connecting to MQTT server: " + e.getMessage());
        }
    }


    public void connectMongo() {
        String mongoURI = "mongodb://";
        if (Boolean.parseBoolean(ReadFromMQTTToMongoDB.mongoAuthentication)) {
            mongoURI += ReadFromMQTTToMongoDB.mongoUser + ":" + ReadFromMQTTToMongoDB.mongoPassword + "@";
        }
        mongoURI += ReadFromMQTTToMongoDB.mongoAddress;

        if (!ReadFromMQTTToMongoDB.mongoReplica.equals("false")) {
            mongoURI += "/?replicaSet=" + ReadFromMQTTToMongoDB.mongoReplica;
            if (Boolean.parseBoolean(ReadFromMQTTToMongoDB.mongoAuthentication)) {
                mongoURI += "&authSource=admin";
            }
        } else if (Boolean.parseBoolean(ReadFromMQTTToMongoDB.mongoAuthentication)) {
            mongoURI += "/?authSource=admin";
        }

        MongoClientURI uri = new MongoClientURI(mongoURI);
        MongoClient mongoClient = new MongoClient(uri);
        DB db = mongoClient.getDB(ReadFromMQTTToMongoDB.mongoDatabase);
        mongocoltemp = db.getCollection(ReadFromMQTTToMongoDB.mongoCollectionTemp);
        mongocolmov = db.getCollection(ReadFromMQTTToMongoDB.mongoCollectionMov);
        mongocolout = db.getCollection(ReadFromMQTTToMongoDB.mongoCollectionOut);
    }

    @Override
    public void messageArrived(String topic, MqttMessage message) {
        try {
            DBObject document_json = (DBObject) JSON.parse(message.toString());
            documentLabel.append(message + "\n");

            if (mongocolmov != null && topic.equals(cloudTopicMov)) {
                mongocolmov.insert(document_json);
            } else if (mongocoltemp != null && topic.equals(cloudTopicTemp)) {
                mongocoltemp.insert(document_json);
            }
        } catch (JSONParseException e) {
            logger.log(Level.WARNING, "Invalid JSON string: " + message.toString());
        }
    }

    @Override
    public void connectionLost(Throwable cause) {
        logger.log(Level.WARNING, "Connection to MQTT broker lost. Reason: {0}", cause.getMessage());
        logger.log(Level.SEVERE, "Stack trace: ", cause);
    }

    @Override
    public void deliveryComplete(IMqttDeliveryToken token) {
        try {
            logger.log(Level.INFO, "Message delivery complete: {0}", token.getMessage());
        } catch (MqttException e) {
            logger.log(Level.SEVERE, "Error getting message from delivery token: {0}", e.getMessage());
        }
    }
}
